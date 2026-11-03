/* Copyright 2026 Mobs. MIT licensed. Independent native console suggestions.
 * Exact 0.8.117 UConsole: list B8, trie E0, matches 108, runtime-ready D4.
 * Shipping BuildRuntimeAutoCompleteList is a ret stub. The native input/filter
 * and dropdown remain intact. Populate their data; never hook input or execute it.
 */
#include <windows.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <wchar.h>
static void *(*engine_realloc)(void *,size_t,uint32_t);
static void (*engine_free)(void *);
static void *allocate(void *p,size_t n) { return engine_realloc(p,n,0); }
#define UX_REALLOC allocate
#define UX_FREE engine_free
#include "autocomplete_tree.h"
typedef struct { UxArray command,description; uint32_t color,padding; } Entry;
_Static_assert(sizeof(Entry)==0x28,"Unreal autocomplete entry");
static HMODULE self_module;
static unsigned char *autocomplete_gate;
static unsigned int changed_gate;

static int readable(const void *p,size_t n) {
    MEMORY_BASIC_INFORMATION m;
    if(!p || !VirtualQuery(p,&m,sizeof(m)) || m.State!=MEM_COMMIT || (m.Protect&(PAGE_NOACCESS|PAGE_GUARD))) return 0;
    return (uintptr_t)p+n>=(uintptr_t)p && (uintptr_t)p+n<=(uintptr_t)m.BaseAddress+m.RegionSize;
}
static int writable(const void *p,size_t n) {
    MEMORY_BASIC_INFORMATION m;
    return readable(p,n) && VirtualQuery(p,&m,sizeof(m)) &&
        (m.Protect&(PAGE_READWRITE|PAGE_WRITECOPY|PAGE_EXECUTE_READWRITE|PAGE_EXECUTE_WRITECOPY));
}
static void restore_gate(void) {
    if(autocomplete_gate && writable(autocomplete_gate,2)) {
        for(unsigned int i=0;i<2;i++)
            if((changed_gate&(1u<<i)) && autocomplete_gate[i]==1) autocomplete_gate[i]=0;
    }
    autocomplete_gate=NULL; changed_gate=0;
}
static int valid_array(const UxArray *a,int maximum,size_t stride) {
    return readable(a,sizeof(*a)) && a->count>=0 && a->count<=maximum && a->capacity>=a->count &&
        a->capacity<=maximum*4 && (!a->capacity || readable(a->data,(size_t)a->capacity*stride));
}
static int string(const UxArray *s,int maximum) {
    return valid_array(s,maximum,2) && (!s->count || ((uint16_t *)s->data)[s->count-1]==0);
}
static int entries(const UxArray *a) {
    if(!valid_array(a,12000,sizeof(Entry))) return 0;
    for(int i=0;i<a->count;i++) {
        const Entry *e=(Entry *)a->data+i;
        if(!string(&e->command,256) || !string(&e->description,4096)) return 0;
    }
    return 1;
}
static int tree_valid(const UxNode *node,int count,int depth,const void **seen,int *total) {
    if(depth>255 || ++*total>65536 || !readable(node,sizeof(*node)) ||
        !valid_array(&node->indices,12000,4) || !valid_array(&node->children,256,sizeof(void *))) return 0;
    size_t slot=((uintptr_t)node>>3)%131072;
    while(seen[slot]) { if(seen[slot]==node) return 0; slot=(slot+1)%131072; }
    seen[slot]=node;
    for(int i=0;i<node->indices.count;i++) {
        int index=((int *)node->indices.data)[i]; if(index<0 || index>=count) return 0;
    }
    for(int i=0;i<node->children.count;i++)
        if(!tree_valid(((UxNode **)node->children.data)[i],count,depth+1,seen,total)) return 0;
    return 1;
}
static int owned(const Entry *entry) {
    const wchar_t *name=entry->command.data,*description=entry->description.data;
    return entry->command.count>0 && entry->description.count>=8 &&
        (!wcscmp(name,L"mobs") || !wcsncmp(name,L"mobs.",5) || !wcscmp(name,L"help")) &&
        !wcsncmp(description,L"[Mobs] ",7);
}
static int clone_string(UxArray *to,const UxArray *from) {
    if(!from->count) return 1;
    to->data=allocate(NULL,(size_t)from->count*2);
    if(!to->data) return 0;
    memcpy(to->data,from->data,(size_t)from->count*2); to->count=to->capacity=from->count; return 1;
}
static int utf8_string(UxArray *to,const char *text) {
    int n=MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,text,-1,NULL,0);
    if(n<=0 || n>4096) return 0;
    to->data=allocate(NULL,(size_t)n*2); if(!to->data) return 0;
    to->count=to->capacity=n;
    return MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,text,-1,to->data,n)==n;
}
static void destroy_entries(UxArray *a) {
    for(int i=0;i<a->count;i++) {
        Entry *e=(Entry *)a->data+i;
        engine_free(e->command.data); engine_free(e->description.data);
    }
    engine_free(a->data); memset(a,0,sizeof(*a));
}
__declspec(dllexport) int mobs_ux_run(void *unused) {
    (void)unused;
    char path[MAX_PATH],request[MAX_PATH],response[MAX_PATH],line[2048];
    GetModuleFileNameA(self_module,path,MAX_PATH);
    char *slash=strrchr(path,'\\'); if(!slash) return 0; slash[1]=0;
    snprintf(request,sizeof(request),"%sux.request",path); snprintf(response,sizeof(response),"%sux.response",path);
    FILE *in=fopen(request,"r"),*out=fopen(response,"w");
    if(!out) { if(in) fclose(in); return 0; }
    UxArray next={0}; UxNode root={0}; const void **seen=NULL;
    unsigned long long address=0; int enable=0,count=0,committed=0;
    if(!in || !fgets(line,sizeof(line),in) || sscanf(line,"MOBS_UX_1 %llu %d %d",&address,&enable,&count)!=3 ||
        enable<0 || enable>1 || count<0 || count>6000 || (!enable && count)) {
        fprintf(out,"ERROR Invalid autocomplete request\n"); goto finish;
    }
    unsigned char *base=(unsigned char *)GetModuleHandleA(NULL);
    IMAGE_DOS_HEADER *dos=(IMAGE_DOS_HEADER *)base;
    IMAGE_NT_HEADERS64 *pe=(IMAGE_NT_HEADERS64 *)(base+dos->e_lfanew);
    const unsigned char update_sig[]={0x40,0x55,0x53,0x41,0x55,0x41,0x56,0x48,0x8b,0xec,0x48,0x83,0xec,0x48};
    const unsigned char alloc_sig[]={0x48,0x89,0x5c,0x24,0x08,0x48,0x89,0x74,0x24,0x10,0x57,0x48,0x83,0xec,0x20};
    const unsigned char free_sig[]={0x48,0x85,0xc9,0x74,0x2e,0x53,0x48,0x83,0xec,0x20};
    if(pe->FileHeader.TimeDateStamp!=0x6836c1ba || pe->OptionalHeader.SizeOfImage!=0x9dfd000 ||
        memcmp(base+0x3fa8a70,update_sig,sizeof(update_sig)) || memcmp(base+0x1137c70,alloc_sig,sizeof(alloc_sig)) ||
        memcmp(base+0x1128900,free_sig,sizeof(free_sig)) || *(void **)(base+0x7b97c28+0x318)!=base+0x10b1ae0) {
        fprintf(out,"ERROR Unsupported game binary; autocomplete refused\n"); goto finish;
    }
    unsigned char *console=(unsigned char *)(uintptr_t)address;
    if(!readable(console,0x160) || *(void **)console!=base+0x7b97c28 || (*(uint32_t *)(console+8)&0x60000000)) {
        fprintf(out,"ERROR Unsupported console object\n"); goto finish;
    }
    /* Shipping also initializes the native autocomplete gate to false. It is
     * TConsoleVariableData<bool>: game/render values at byte 0/1. Change only
     * these two UI flags in memory and restore values we changed on off/unload. */
    unsigned char *gate=*(unsigned char **)(base+0x94326e0);
    if(!writable(gate,2) || gate[0]>1 || gate[1]>1 || (autocomplete_gate && autocomplete_gate!=gate)) {
        fprintf(out,"ERROR Unexpected autocomplete switch; unchanged\n"); goto finish;
    }
    UxArray *list=(UxArray *)(console+0xb8);
    UxNode *old_root=(UxNode *)(console+0xe0);
    if(!entries(list) || !entries((UxArray *)(console+0x108)) || !string((UxArray *)(console+0x78),256)) {
        fprintf(out,"ERROR Unexpected console arrays; unchanged\n"); goto finish;
    }
    seen=HeapAlloc(GetProcessHeap(),HEAP_ZERO_MEMORY,131072*sizeof(void *));
    int total=0;
    if(!seen || !tree_valid(old_root,list->count,0,seen,&total)) {
        fprintf(out,"ERROR Unexpected console trie; unchanged\n"); goto finish;
    }
    engine_realloc=(void *(*)(void *,size_t,uint32_t))(base+0x1137c70);
    engine_free=(void (*)(void *))(base+0x1128900);
    next.capacity=list->count+count;
    if(next.capacity>12000) { fprintf(out,"ERROR Too many console entries; unchanged\n"); goto finish; }
    if(next.capacity) {
        next.data=allocate(NULL,(size_t)next.capacity*sizeof(Entry));
        if(!next.data) goto allocation_error;
        memset(next.data,0,(size_t)next.capacity*sizeof(Entry));
    }
    for(int i=0;i<list->count;i++) {
        Entry *source=(Entry *)list->data+i;
        if(owned(source)) continue;
        Entry *target=(Entry *)next.data+next.count++;
        if(!clone_string(&target->command,&source->command) || !clone_string(&target->description,&source->description)) goto allocation_error;
        target->color=source->color;
    }
    int added=0;
    for(int i=0;i<count;i++) {
        if(!fgets(line,sizeof(line),in) || !strchr(line,'\n')) { fprintf(out,"ERROR Incomplete autocomplete entry; unchanged\n"); goto finish; }
        line[strcspn(line,"\r\n")]=0;
        char *description=strchr(line,'\t');
        if(!description) { fprintf(out,"ERROR Invalid autocomplete entry; unchanged\n"); goto finish; }
        *description++=0;
        if(strlen(line)>240 || (strcmp(line,"mobs") && strncmp(line,"mobs.",5) && strcmp(line,"help"))) {
            fprintf(out,"ERROR Non-Mobs autocomplete entry refused\n"); goto finish;
        }
        for(char *at=line;*at;at++) if((unsigned char)*at<32) { fprintf(out,"ERROR Invalid command text\n"); goto finish; }
        wchar_t command[256];
        if(!MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,line,-1,command,256)) { fprintf(out,"ERROR Invalid command encoding\n"); goto finish; }
        int duplicate=0;
        for(int j=0;j<next.count;j++) {
            Entry *entry=(Entry *)next.data+j;
            if(entry->command.count && !_wcsicmp(command,entry->command.data)) { duplicate=1; break; }
        }
        if(duplicate) continue;
        Entry *target=(Entry *)next.data+next.count++;
        char help[2048]; snprintf(help,sizeof(help),"[Mobs] %.1900s",description);
        if(!utf8_string(&target->command,line) || !utf8_string(&target->description,help)) goto allocation_error;
        target->color=0xff80e0a0; added++;
    }
    int nodes=0;
    UxArray *(*uppercase)(const UxArray *,UxArray *)=(UxArray *(*)(const UxArray *,UxArray *))(base+0x10dfa40);
    for(int i=0;i<next.count;i++) {
        UxArray upper={0}; Entry *entry=(Entry *)next.data+i;
        uppercase(&entry->command,&upper);
        int ok=!upper.count || ux_insert(&root,upper.data,i,&nodes);
        engine_free(upper.data);
        if(!ok) goto allocation_error;
    }
    /* Fully constructed before swapping. Current matches are deep string copies.
     * Preserve typed text, history, console state, lock bit, settings and focus. */
    UxArray previous=*list; UxNode previous_root=*old_root;
    *list=next; *old_root=root; memset(&next,0,sizeof(next)); memset(&root,0,sizeof(root));
    console[0xd4]|=1; committed=1;
    if(enable) {
        autocomplete_gate=gate;
        for(unsigned int i=0;i<2;i++) {
            if(!gate[i]) changed_gate|=1u<<i;
            gate[i]=1;
        }
    } else restore_gate();
    ((void (*)(void *))(base+0x3fa8a70))(console);
    destroy_entries(&previous); ux_destroy(&previous_root);
    fprintf(out,"OK %d\n",added); goto finish;
allocation_error:
    fprintf(out,"ERROR Cannot allocate autocomplete data; unchanged\n");
finish:
    if(engine_free && !committed) { destroy_entries(&next); ux_destroy(&root); }
    if(seen) HeapFree(GetProcessHeap(),0,(void *)seen);
    if(in) fclose(in);
    fclose(out); return 0;
}
BOOL WINAPI DllMain(HINSTANCE module,DWORD reason,LPVOID reserved) {
    if(reason==DLL_PROCESS_ATTACH) self_module=module;
    else if(reason==DLL_PROCESS_DETACH && !reserved) restore_gate();
    return TRUE;
}
