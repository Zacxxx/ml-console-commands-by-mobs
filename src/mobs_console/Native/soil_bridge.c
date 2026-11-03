/* Copyright 2026 Mobs. MIT licensed. Independent exact-build soil adapter.
 * Layout evidence: native fertility reader 0x4cc5310; planted-cell indexing
 * 0x4d3bae0; baseline clamp 0x4c9b29b; grid geometry 0x4cc05e0.
 * Called synchronously on the game thread. No hooks or game/save files patched.
 */
#include <windows.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "soil_cells.h"
#define CELLS (1024*1024)
typedef struct { void *data; int32_t count,capacity; } Array;
typedef SoilChange Change;
static HMODULE self_module;
static Change *undo;
static int undo_count;
static uintptr_t undo_engine,undo_pawn;
static int readable(const void *p,size_t n) {
    MEMORY_BASIC_INFORMATION m;
    if(!p || !VirtualQuery(p,&m,sizeof(m)) || m.State!=MEM_COMMIT || (m.Protect&(PAGE_NOACCESS|PAGE_GUARD))) return 0;
    return (uintptr_t)p+n>=(uintptr_t)p && (uintptr_t)p+n<=(uintptr_t)m.BaseAddress+m.RegionSize;
}
static int array(Array *a,int maximum,size_t stride) {
    return readable(a,sizeof(*a)) && a->count>=0 && a->count<=maximum && a->capacity>=a->count &&
        a->capacity<=maximum*2 && (!a->count || readable(a->data,(size_t)a->count*stride));
}
static int own(unsigned char *region,uintptr_t pawn) {
    return readable(region,0x358) && *(uintptr_t *)(region+0x350)==pawn;
}
static int select_cell(unsigned char *selected,Array *regions,int index,unsigned char *region) {
    if(index<0 || index>=CELLS) return 0;
    if(((void **)regions->data)[index]!=(void *)region) return 1; /* Border cells outside the owned target stay untouched. */
    selected[index]=1; return 1;
}
__declspec(dllexport) int mobs_soil_run(void *unused) {
    (void)unused;
    char path[MAX_PATH],request[MAX_PATH],response[MAX_PATH];
    GetModuleFileNameA(self_module,path,MAX_PATH);
    char *slash=strrchr(path,'\\'); if(!slash) return 0; slash[1]=0;
    snprintf(request,sizeof(request),"%ssoil.request",path); snprintf(response,sizeof(response),"%ssoil.response",path);
    FILE *in=fopen(request,"r"),*out=fopen(response,"w");
    if(!out) { if(in) fclose(in); return 0; }
    unsigned long long engine_address=0,pawn_address=0;
    int mode=0,scope=0,preview=1,mask=7,count=0;
    float value=0;
    unsigned char *selected=NULL; Change *plan=NULL;
    if(!in || fscanf(in,"MOBS_SOIL_1 %llu %llu %d %d %d %d %f %d",
        &engine_address,&pawn_address,&mode,&scope,&preview,&mask,&value,&count)!=8 ||
        mode<0 || mode>3 || scope<0 || scope>1 || preview<0 || preview>1 || mask<1 || mask>7 ||
        !isfinite(value) || value<0 || value>1 || count<0 || count>32) {
        fprintf(out,"ERROR Invalid soil request\n"); goto finish;
    }
    unsigned char *base=(unsigned char *)GetModuleHandleA(NULL);
    IMAGE_DOS_HEADER *dos=(IMAGE_DOS_HEADER *)base;
    IMAGE_NT_HEADERS64 *pe=(IMAGE_NT_HEADERS64 *)(base+dos->e_lfanew);
    const unsigned char sig[]={0x40,0x53,0x48,0x83,0xec,0x50,0x48,0x8d,0x99,0xe8,0x08,0,0};
    if(pe->FileHeader.TimeDateStamp!=0x6836c1ba || pe->OptionalHeader.SizeOfImage!=0x9dfd000 ||
        memcmp(base+0x4cc5310,sig,sizeof(sig)) || *(float *)(base+0x7f87754)!=217.96875f ||
        *(float *)(base+0x7f87778)!=111600.0f) {
        fprintf(out,"ERROR Unsupported game binary; soil refused\n"); goto finish;
    }
    unsigned char *engine=(unsigned char *)(uintptr_t)engine_address;
    if(!readable(engine,0x910)) { fprintf(out,"ERROR Invalid simulation\n"); goto finish; }
    Array *current=(Array *)(engine+0x8e0), *original=(Array *)(engine+0x8f0), *regions=(Array *)(engine+0x900);
    if(!array(current,CELLS,16) || !array(original,CELLS,16) || !array(regions,CELLS,8) ||
        current->count!=CELLS || original->count!=CELLS || regions->count!=CELLS) {
        fprintf(out,"ERROR Unexpected soil grid layout\n"); goto finish;
    }
    float (*now)[4]=current->data, (*baseline)[4]=original->data;
    if(mode==2) {
        if(!undo_count || undo_engine!=(uintptr_t)engine || undo_pawn!=(uintptr_t)pawn_address) {
            fprintf(out,"ERROR No soil undo for this settlement\n"); goto finish;
        }
        for(int i=0;i<undo_count;i++) {
            Change *c=undo+i;
            if(!own(((void **)regions->data)[c->index],(uintptr_t)pawn_address) ||
                now[c->index][c->channel]!=c->after || baseline[c->index][c->channel]!=c->base_after) {
                fprintf(out,"ERROR Soil changed since edit; undo refused\n"); goto finish;
            }
        }
        int n=undo_count;
        if(!preview) {
            for(int i=0;i<n;i++) { Change *c=undo+i; now[c->index][c->channel]=c->before; baseline[c->index][c->channel]=c->base_before; }
            HeapFree(GetProcessHeap(),0,undo); undo=NULL; undo_count=0;
        }
        fprintf(out,"OK %d\n",n); goto finish;
    }
    selected=HeapAlloc(GetProcessHeap(),HEAP_ZERO_MEMORY,CELLS);
    if(!selected) { fprintf(out,"ERROR Cannot allocate soil preflight\n"); goto finish; }
    if(mode==3) fprintf(out,"PLANTS\n");
    int printed=0,total_plants=0;
    for(int f=0;f<count;f++) {
        unsigned long long address=0;
        if(fscanf(in,"%llu",&address)!=1) { fprintf(out,"ERROR Missing plot\n"); goto finish; }
        unsigned char *building=(unsigned char *)(uintptr_t)address;
        if(!readable(building,0x748) || *(void **)(building+0x2e8)!=engine ||
            !own(*(void **)(building+0x2c8),(uintptr_t)pawn_address)) {
            fprintf(out,"ERROR Invalid or foreign plot\n"); goto finish;
        }
        unsigned char *region=*(void **)(building+0x2c8);
        if(scope==0 || mode==3) {
            Array *plants=(Array *)(building+0x530);
            if(!array(plants,200000,0xd0)) { fprintf(out,"ERROR Invalid plant array\n"); goto finish; }
            total_plants+=plants->count;
            if(mode==3) fprintf(out,"Building %d: %d plants\n",f+1,plants->count);
            for(int p=0;p<plants->count;p++) {
                unsigned char *plant=(unsigned char *)plants->data+(size_t)p*0xd0;
                if(mode==3) {
                    if(printed<100) {
                        double *pos=(double *)(plant+8);
                        fprintf(out,"  type=%u pos=(%.1f,%.1f,%.1f) growth=%.3f yield=%d soil-cell=%d\n",
                            plant[0],pos[0],pos[1],pos[2],*(float *)(plant+0x24),*(int *)(plant+0x4c),*(int *)(plant+0xbc));
                        printed++;
                    }
                    continue;
                }
                int index=*(int *)(plant+0xbc);
                if(!select_cell(selected,regions,index,region)) { fprintf(out,"ERROR Invalid planted soil cell\n"); goto finish; }
            }
        } else {
            double *center=(double *)(building+0x728);
            float radius=*(float *)(building+0x740);
            if(!building[0x721] || !isfinite(center[0]) || !isfinite(center[1]) ||
                !isfinite(radius) || radius<=0 || radius>25000) {
                fprintf(out,"ERROR Select buildings with an explicit limited work area (radius <=25000)\n"); goto finish;
            }
            for(int index=0;index<CELLS;index++) {
                if(soil_in_circle(index,center[0],center[1],radius)) select_cell(selected,regions,index,region);
            }
        }
    }
    if(mode==3) { fprintf(out,"Total %d plants; showing up to 100. Read only.\n",total_plants); goto finish; }
    int n=0;
    for(int i=0;i<CELLS;i++) if(selected[i]) for(int channel=0;channel<3;channel++) if(mask&(1<<channel)) {
        Change change;
        int state=soil_plan(i,channel,now[i][channel],baseline[i][channel],mode==1,value,&change);
        if(state<0) { fprintf(out,"ERROR Invalid fertility values; no changes\n"); goto finish; }
        n+=state;
    }
    if(preview || !n) { fprintf(out,"OK %d\n",n); goto finish; }
    plan=HeapAlloc(GetProcessHeap(),0,(size_t)n*sizeof(Change));
    if(!plan) { fprintf(out,"ERROR Cannot allocate soil undo; no changes\n"); goto finish; }
    int k=0;
    for(int i=0;i<CELLS;i++) if(selected[i]) for(int channel=0;channel<3;channel++) if(mask&(1<<channel)) {
        Change change;
        int state=soil_plan(i,channel,now[i][channel],baseline[i][channel],mode==1,value,&change);
        if(state<0 || k>=n+1) { fprintf(out,"ERROR Soil changed during preflight; no changes\n"); goto finish; }
        if(state==1) {
            if(k>=n) { fprintf(out,"ERROR Soil plan grew; no changes\n"); goto finish; }
            plan[k++]=change;
        }
    }
    if(k!=n) { fprintf(out,"ERROR Soil changed during preflight; no changes\n"); goto finish; }
    if(undo) HeapFree(GetProcessHeap(),0,undo);
    undo=plan; plan=NULL; undo_count=n; undo_engine=(uintptr_t)engine; undo_pawn=(uintptr_t)pawn_address;
    for(int i=0;i<n;i++) { Change *c=undo+i; now[c->index][c->channel]=c->after; baseline[c->index][c->channel]=c->base_after; }
    fprintf(out,"OK %d\n",n);
finish:
    if(selected) HeapFree(GetProcessHeap(),0,selected);
    if(plan) HeapFree(GetProcessHeap(),0,plan);
    if(in) fclose(in);
    fclose(out); return 0;
}
BOOL WINAPI DllMain(HINSTANCE module,DWORD reason,LPVOID reserved) {
    (void)reserved; if(reason==DLL_PROCESS_ATTACH) self_module=module; return TRUE;
}
