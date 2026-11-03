/* Original Mobs exact-build regional perk respec adapter. MIT licensed.
 * Runs on the game thread; removes trivial sparse entries without reallocating.
 */
#include <windows.h>
#include <stdio.h>
#include "perk_containers.h"
static HMODULE self_module;
static int readable(const void *p,size_t n) {
    MEMORY_BASIC_INFORMATION m;
    return p && VirtualQuery(p,&m,sizeof(m)) && m.State==MEM_COMMIT &&
        !(m.Protect&(PAGE_NOACCESS|PAGE_GUARD)) &&
        (uintptr_t)p+n>=(uintptr_t)p &&
        (uintptr_t)p+n<=(uintptr_t)m.BaseAddress+m.RegionSize;
}
static int container_valid(unsigned char *set,int stride,int max_key) {
    if (!readable(set,80)) return 0;
    int count=get_i32(set,8),capacity=get_i32(set,12),bits=get_i32(set,40);
    int hash_count=get_i32(set,72),free_count=get_i32(set,52);
    if(count<0 || count>1024 || capacity<count || capacity>65536 || bits!=count ||
        get_i32(set,44)<bits || free_count<0 || free_count>count ||
        hash_count<0 || hash_count>65536 || (hash_count && (hash_count&(hash_count-1)))) return 0;
    if(!count) return free_count==0;
    if(!hash_count || !readable(*(void **)set,(size_t)count*stride) ||
        !readable(set_bits(set),(size_t)((count+31)/32)*4) ||
        !readable(set_hash(set),(size_t)hash_count*4)) return 0;
    unsigned char *data=*(unsigned char **)set;
    int occupied=0,seen[256]={0},reached[1024]={0};
    for(int i=0;i<count;i++) if(set_occupied(set,i)) {
        unsigned char *node=data+i*stride;
        if(node[0]<1 || node[0]>max_key || seen[node[0]]++) return 0;
        int hash=get_i32(node,stride-4);
        if(hash<0 || hash>=hash_count || hash!=(node[0]&(hash_count-1))) return 0;
        occupied++;
    }
    if(occupied!=count-free_count) return 0;
    for(int h=0;h<hash_count;h++) {
        int i=set_hash(set)[h],steps=0;
        while(i!=-1) {
            if(i<0 || i>=count || !set_occupied(set,i) || ++steps>count || reached[i]++ ||
                get_i32(data+i*stride,stride-4)!=h) return 0;
            i=get_i32(data+i*stride,stride-8);
        }
    }
    for(int i=0;i<count;i++) if(set_occupied(set,i) && !reached[i]) return 0;
    int first=get_i32(set,48),previous=-1,free_seen=0;
    while(first!=-1) {
        if(first<0 || first>=count || set_occupied(set,first) || ++free_seen>count ||
            get_i32(data+first*stride,0)!=previous) return 0;
        previous=first; first=get_i32(data+first*stride,4);
    }
    return free_seen==free_count;
}
static int signature(unsigned char *base,uintptr_t rva,const unsigned char *bytes,size_t n) {
    return readable(base+rva,n) && !memcmp(base+rva,bytes,n);
}
/* Read metadata only: this does not open or alter any game save contents. */
__declspec(dllexport) int mobs_perks_files(void *unused) {
    (void)unused;
    char path[MAX_PATH],response[MAX_PATH],saved[MAX_PATH],pattern[MAX_PATH];
    GetModuleFileNameA(self_module,path,MAX_PATH);
    char *slash=strrchr(path,'\\'); if(!slash) return 0; slash[1]=0;
    snprintf(response,sizeof(response),"%sperks.files",path);
    snprintf(saved,sizeof(saved),"%sState",path); CreateDirectoryA(saved,NULL);
    FILE *out=fopen(response,"w"); if(!out) return 0;
    char local[MAX_PATH];
    DWORD length=GetEnvironmentVariableA("LOCALAPPDATA",local,MAX_PATH);
    if(!length || length>=MAX_PATH) { fprintf(out,"ERROR Missing save folder\n"); fclose(out); return 0; }
    if(snprintf(saved,sizeof(saved),"%s\\ManorLords\\Saved\\SaveGames",local)>=(int)sizeof(saved) ||
        snprintf(pattern,sizeof(pattern),"%s\\*.sav",saved)>=(int)sizeof(pattern)) {
        fprintf(out,"ERROR Save folder path too long\n"); fclose(out); return 0;
    }
    fprintf(out,"OK %lu\n",GetCurrentProcessId());
    WIN32_FIND_DATAA info;
    HANDLE search=FindFirstFileA(pattern,&info);
    if(search!=INVALID_HANDLE_VALUE) {
        do {
            int safe=1;
            for(const char *c=info.cFileName;*c;c++)
                if(!((*c>='a'&&*c<='z') || (*c>='A'&&*c<='Z') ||
                    (*c>='0'&&*c<='9') || *c=='_' || *c=='-' || *c=='.')) safe=0;
            if(!safe || strstr(info.cFileName,"_descr") ||
                (info.dwFileAttributes&FILE_ATTRIBUTE_DIRECTORY)) continue;
            char file[MAX_PATH];
            if(snprintf(file,sizeof(file),"%s\\%s",saved,info.cFileName)>=(int)sizeof(file)) continue;
            /* Refuse files still open for writing. The next poll will see them
             * after the game's save writer has closed them. */
            HANDLE handle=CreateFileA(file,FILE_READ_ATTRIBUTES,FILE_SHARE_READ,NULL,
                OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
            BY_HANDLE_FILE_INFORMATION completed;
            if(handle!=INVALID_HANDLE_VALUE) {
                if(GetFileInformationByHandle(handle,&completed) &&
                    (completed.nFileSizeLow || completed.nFileSizeHigh))
                    fprintf(out,"%s %08lx%08lx_%08lx%08lx\n",info.cFileName,
                        completed.ftLastWriteTime.dwHighDateTime,completed.ftLastWriteTime.dwLowDateTime,
                        completed.nFileSizeHigh,completed.nFileSizeLow);
                CloseHandle(handle);
            }
        } while(FindNextFileA(search,&info));
        FindClose(search);
    }
    fclose(out); return 0;
}
/* Resolve only verified rows from the actual loaded Tech table. */
static unsigned char *find_row(unsigned char *map,uint64_t name) {
    unsigned char *data=*(unsigned char **)map;
    for(int i=0;i<get_i32(map,8);i++) if(set_occupied(map,i)) {
        uint64_t key; memcpy(&key,data+(size_t)i*24,8);
        if(key==name) return *(unsigned char **)(data+(size_t)i*24+8);
    }
    return NULL;
}
static int table_valid(unsigned char *map) {
    if(!readable(map,80)) return 0;
    int count=get_i32(map,8),capacity=get_i32(map,12);
    return count>=0 && count<=4096 && capacity>=count && capacity<=65536 &&
        get_i32(map,40)==count && get_i32(map,44)>=count &&
        (!count || (readable(*(void **)map,(size_t)count*24) &&
            readable(set_bits(map),(size_t)((count+31)/32)*4)));
}
static int include_row(unsigned char *row,int desired[123],int extra) {
    if(!readable(row,0xb9) || (extra && row[0xb8]!=1 && row[0xb8]!=3) ||
        !container_valid(row+0x68,12,122)) return 0;
    unsigned char *effects=row+0x68,*data=*(unsigned char **)effects;
    for(int i=0;i<get_i32(effects,8);i++) if(set_occupied(effects,i))
        desired[data[i*12]]=1;
    return 1;
}
__declspec(dllexport) int mobs_perks_run(void *unused) {
    (void)unused;
    char path[MAX_PATH],request[MAX_PATH],response[MAX_PATH];
    GetModuleFileNameA(self_module,path,MAX_PATH);
    char *slash=strrchr(path,'\\'); if(!slash) return 0; slash[1]=0;
    snprintf(request,sizeof(request),"%sperks.request",path);
    snprintf(response,sizeof(response),"%sperks.response",path);
    FILE *in=fopen(request,"r"),*out=fopen(response,"w");
    if(!out) { if(in) fclose(in); return 0; }
    int mask=0,preview=1,extra_count=0,overlay=0;
    unsigned long long region_address=0,pawn_address=0,component_address=0;
    unsigned long long table_address=0;
    uint64_t extras[64]={0};
    char protocol[32]={0};
    if(!in || fscanf(in,"%31s %d %d %llu %llu %llu",protocol,&mask,&preview,
        &region_address,&pawn_address,&component_address)!=6 ||
        (mask!=0 && mask!=1 && mask!=4 && mask!=5) || (preview!=0 && preview!=1)) {
        fprintf(out,"ERROR Invalid perk request\n"); goto finish;
    }
    overlay=!strcmp(protocol,"MOBS_PERKS_2");
    if((!overlay && strcmp(protocol,"MOBS_PERKS_1")) || (overlay &&
        (mask || fscanf(in,"%llu %d",&table_address,&extra_count)!=2 || extra_count<0 || extra_count>64))) {
        fprintf(out,"ERROR Invalid overlay request\n"); goto finish;
    }
    for(int i=0;i<extra_count;i++) {
        unsigned int comparison=0,number=0;
        if(fscanf(in,"%u %u",&comparison,&number)!=2 || !comparison) {
            fprintf(out,"ERROR Invalid card name\n"); goto finish;
        }
        extras[i]=(uint64_t)comparison|((uint64_t)number<<32);
        for(int j=0;j<i;j++) if(extras[j]==extras[i]) {
            fprintf(out,"ERROR Duplicate card request\n"); goto finish;
        }
    }
    unsigned char *base=(unsigned char *)GetModuleHandleA(NULL);
    IMAGE_DOS_HEADER *dos=(IMAGE_DOS_HEADER *)base;
    IMAGE_NT_HEADERS64 *pe=(IMAGE_NT_HEADERS64 *)(base+dos->e_lfanew);
    const unsigned char rebuild_sig[]={0x48,0x89,0x5c,0x24,0x20,0x55,0x56,0x57,0x41,0x54};
    const unsigned char unlock_sig[]={0x48,0x89,0x5c,0x24,0x10,0x48,0x89,0x6c,0x24,0x20};
    const unsigned char notify_sig[]={0x48,0x89,0x6c,0x24,0x20,0x41,0x56,0x48,0x83,0xec,0x20};
    const unsigned char add_sig[]={0x48,0x89,0x5c,0x24,0x08};
    if(pe->FileHeader.TimeDateStamp!=0x6836c1ba || pe->OptionalHeader.SizeOfImage!=0x9dfd000 ||
        !signature(base,0x4c509d0,rebuild_sig,sizeof(rebuild_sig)) ||
        !signature(base,0x4c46670,unlock_sig,sizeof(unlock_sig)) ||
        !signature(base,0x4c453d0,notify_sig,sizeof(notify_sig)) ||
        !signature(base,0x4b06040,add_sig,sizeof(add_sig))) {
        fprintf(out,"ERROR Unsupported binary; perks refused\n"); goto finish;
    }
    unsigned char *region=(void *)(uintptr_t)region_address,*component=(void *)(uintptr_t)component_address;
    if(!readable(region,0x830) || !readable(component,0x198) ||
        *(uintptr_t *)(region+0x350)!=(uintptr_t)pawn_address ||
        *(void **)(region+0x828)!=component || *(void **)(component+0x20)!=region ||
        !readable(*(void **)(component+0x140),0x60) ||
        !container_valid(component+0xa0,20,3) || !container_valid(component+0xf0,12,122)) {
        fprintf(out,"ERROR Invalid region or unsupported perk containers; no changes\n"); goto finish;
    }
    /* Origins is a prerequisite for Rural Foundations: reset descendants too. */
    if(mask&1) mask|=4;
    unsigned char *slots=component+0xa0,*effects=component+0xf0;
    if(overlay) {
        unsigned char *table=(void *)(uintptr_t)table_address;
        if(!readable(table,0x80) || !readable(*(void **)table,0x2f0)) {
            fprintf(out,"ERROR Invalid card table\n"); goto finish;
        }
        uintptr_t method=(*(uintptr_t **)table)[0x2e8/8];
        if(method<(uintptr_t)base || method>=(uintptr_t)base+pe->OptionalHeader.SizeOfImage) {
            fprintf(out,"ERROR Unexpected card table virtual method\n"); goto finish;
        }
        void *(*get_map)(void *)=(void *)method;
        unsigned char *rows=get_map(table);
        if(!table_valid(rows)) { fprintf(out,"ERROR Invalid card rows\n"); goto finish; }
        int desired[123]={0},before[123]={0},effect_count=0;
        unsigned char *data=*(unsigned char **)slots;
        /* Keep every primary card, including unrelated Trade Privileges. */
        for(int i=0;i<get_i32(slots,8);i++) if(set_occupied(slots,i)) {
            uint64_t name; memcpy(&name,data+i*20+4,8);
            if(!include_row(find_row(rows,name),desired,0)) {
                fprintf(out,"ERROR Primary card missing from this table; no changes\n"); goto finish;
            }
        }
        for(int i=0;i<extra_count;i++) if(!include_row(find_row(rows,extras[i]),desired,1)) {
            fprintf(out,"ERROR Extra card missing or not tier 1/2; no changes\n"); goto finish;
        }
        for(int i=1;i<123;i++) effect_count+=desired[i]!=0;
        if(!preview) {
            data=*(unsigned char **)effects;
            for(int i=0;i<get_i32(effects,8);i++) if(set_occupied(effects,i)) {
                unsigned char key=data[i*12]; before[key]=1;
                if(!desired[key]) set_remove(effects,12,i);
            }
            void (*add)(void *,void *,void *,void *)=(void *)(base+0x4b06040);
            void (*notify)(void *,unsigned char)=(void *)(base+0x4c453d0);
            for(int i=1;i<123;i++) if(desired[i] && !before[i]) {
                unsigned char key=(unsigned char)i; int result[2]={0};
                add(effects,result,&key,NULL);
            }
            for(int i=1;i<123;i++) if(before[i]!=desired[i]) notify(component,(unsigned char)i);
            if(!container_valid(effects,12,122)) {
                fprintf(out,"ERROR Effect container changed unexpectedly; stop using perk commands\n"); goto finish;
            }
            for(int i=1;i<123;i++) if(set_contains(effects,12,(unsigned char)i)!=desired[i]) {
                fprintf(out,"ERROR Game did not apply all perk effects\n"); goto finish;
            }
        }
        fprintf(out,"OVERLAY %d %d\n",extra_count,effect_count); goto finish;
    }
    int removed1=0,removed2=0,old_effects[123]={0};
    for(int i=0;i<get_i32(slots,8);i++) if(set_occupied(slots,i)) {
        unsigned char key=(*(unsigned char **)slots)[i*20];
        if(mask&(1<<(key-1))) {
            if(key==1) removed1++; else if(key==3) removed2++;
        }
    }
    if(!preview && mask && (removed1 || removed2)) {
        for(int i=0;i<get_i32(slots,8);i++) if(set_occupied(slots,i)) {
            unsigned char key=(*(unsigned char **)slots)[i*20];
            if(mask&(1<<(key-1))) set_remove(slots,20,i);
        }
        for(int i=0;i<get_i32(effects,8);i++) if(set_occupied(effects,i)) {
            old_effects[(*(unsigned char **)effects)[i*12]]=1;
            set_remove(effects,12,i);
        }
        /* Same map restoration path used by native save loading. Rebuild all
         * remaining card effects, preserving unrelated slots and subscribers. */
        void (*rebuild)(void *,void *)=(void *)(base+0x4c509d0);
        rebuild(component,slots);
        void (*notify)(void *,unsigned char)=(void *)(base+0x4c453d0);
        for(int effect=1;effect<123;effect++)
            if(old_effects[effect] && !set_contains(effects,12,(unsigned char)effect))
                notify(component,(unsigned char)effect);
    }
    unsigned char (*unlocked)(void *,unsigned char)=(void *)(base+0x4c46670);
    int available1=unlocked(component,1) && !set_contains(slots,20,1);
    int available2=unlocked(component,3) && !set_contains(slots,20,3);
    fprintf(out,"OK %d %d %d %d\n",removed1,removed2,available1,available2);
finish:
    if(in) fclose(in);
    fclose(out); return 0;
}
BOOL WINAPI DllMain(HINSTANCE module,DWORD reason,LPVOID reserved) {
    (void)reserved; if(reason==DLL_PROCESS_ATTACH) self_module=module; return TRUE;
}
