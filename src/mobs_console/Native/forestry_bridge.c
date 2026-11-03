/* Original Mobs implementation. MIT licensed. Exact-build native forestry adapter.
 * Invoked synchronously from Lua on the game thread. Does not install hooks.
 */
#include <windows.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "forestry_growth.h"

typedef struct { unsigned char *data; int32_t count, capacity; } Array;
typedef struct { double x,y,z; } Vec;
typedef struct __attribute__((aligned(16))) { double values[12]; } Transform;
static HMODULE self_module;
static int readable(const void *p, size_t n) {
    MEMORY_BASIC_INFORMATION m;
    if (!p || !VirtualQuery(p,&m,sizeof(m)) || m.State!=MEM_COMMIT ||
        (m.Protect & (PAGE_NOACCESS|PAGE_GUARD))) return 0;
    return (uintptr_t)p+n >= (uintptr_t)p && (uintptr_t)p+n <= (uintptr_t)m.BaseAddress+m.RegionSize;
}
static int array_valid(Array *a) {
    return a->count>=0 && a->count<=50000 && a->capacity>=a->count && a->capacity<=100000 &&
        (!a->count || readable(a->data,(size_t)a->count*128));
}
static int signature(unsigned char *base, uintptr_t rva, const unsigned char *bytes, size_t n) {
    return readable(base+rva,n) && !memcmp(base+rva,bytes,n);
}
typedef struct { void *component; Transform transform; } Tree;
typedef struct { unsigned char *base,*region; Array *growing; int limited; double x,y,radius; } GrowthContext;
static int pointer_array(Array *a,int maximum) {
    return readable(a,sizeof(*a)) && a->count>=0 && a->count<=maximum &&
        a->capacity>=a->count && a->capacity<=100000 &&
        (!a->count || readable(a->data,(size_t)a->count*8));
}
static int same_position(const double *a,const double *b) {
    double x=a[0]-b[0],y=a[1]-b[1],z=a[2]-b[2];
    return x*x+y*y+z*z<=1.0;
}
static int registered(Array *growing,void *component,Transform *transform) {
    for(int i=0;i<growing->count;i++) {
        unsigned char *entry=growing->data+(size_t)i*128;
        if(*(void **)entry==component && same_position((double *)(entry+0x30),transform->values+4)) return 1;
    }
    return 0;
}
/* Exact mesh identities from the native growth state machine, not name-based
 * guesses. Underbrush, rocks, dead trees and other small decorative meshes
 * are never enrolled just because they look young. */
static int collect_untracked(unsigned char *base,unsigned char *region,Array *growing,Tree *trees,int *count) {
    unsigned char *engine=*(unsigned char **)(region+0x318);
    if(!readable(engine,0xb20)) return 0;
    Array *young=(Array *)(engine+0x810),*normal=(Array *)(engine+0xb10);
    Array *foliage=(Array *)(region+0xf38);
    if(!pointer_array(young,128) || young->count<2 || !pointer_array(normal,128) || normal->count<4 ||
        !pointer_array(foliage,256)) return 0;
    void *stages[]={((void **)young->data)[0],((void **)young->data)[1],((void **)normal->data)[3]};
    for(int i=0;i<3;i++) if(!readable(stages[i],0x28)) return 0;
    unsigned char (*get_transform)(void *,int,Transform *,unsigned char)=(void *)(base+0x39769b0);
    *count=0;
    for(int c=0;c<foliage->count;c++) {
        unsigned char *component=((unsigned char **)foliage->data)[c];
        if(!readable(component,0xa30)) return 0;
        void *mesh=*(void **)(component+0x528);
        if(mesh!=stages[0] && mesh!=stages[1] && mesh!=stages[2]) continue;
        Array *instances=(Array *)(component+0x5c0);
        if(instances->count<0 || instances->count>100000 || instances->capacity<instances->count ||
            (instances->count && !readable(instances->data,(size_t)instances->count*128))) return 0;
        for(int i=0;i<instances->count;i++) {
            Transform transform={0};
            if(!get_transform(component,i,&transform,1)) return 0;
            int finite=1;
            for(int v=0;v<12;v++) if(!isfinite(transform.values[v])) finite=0;
            if(!finite) return 0;
            /* Removed/hidden foliage may retain zero-scale instance slots. */
            if(fabs(transform.values[8])<=0.0001 || fabs(transform.values[9])<=0.0001 || fabs(transform.values[10])<=0.0001) continue;
            if(registered(growing,component,&transform)) continue;
            int duplicate=0;
            for(int t=0;t<*count;t++) if(trees[t].component==component &&
                same_position(trees[t].transform.values+4,transform.values+4)) { duplicate=1; break; }
            if(duplicate) continue;
            if(*count+growing->count>=50000) return 0;
            trees[*count].component=component; trees[*count].transform=transform; (*count)++;
        }
    }
    return 1;
}
static int append_tree(unsigned char *base,Array *growing,void *component,Transform *transform) {
    int index=growing->count;
    if(index==growing->capacity) {
        void (*reserve)(Array *,int)=(void *)(base+0x4b21260);
        growing->count=index+1; reserve(growing,index); growing->count=index;
    }
    if(!readable(growing->data,(size_t)(index+1)*128)) return 0;
    void (*construct)(void *,void *,Transform *,int)=(void *)(base+0x4da0330);
    construct(growing->data+(size_t)index*128,component,transform,-1);
    growing->count=index+1; return 1;
}
static int growth_count(void *pointer) { return ((GrowthContext *)pointer)->growing->count; }
static int advance_tree(void *pointer,int index) {
    GrowthContext *ctx=pointer; Array *growing=ctx->growing;
    if(!array_valid(growing) || index>=growing->count) return -1;
    unsigned char *entry=growing->data+(size_t)index*128;
    if(ctx->limited) {
        double *position=(double *)(entry+0x30);
        double x=position[0]-ctx->x,y=position[1]-ctx->y;
        if(!isfinite(x) || !isfinite(y)) return -1;
        if(x*x+y*y>ctx->radius*ctx->radius) return 0;
    }
    void *component=*(void **)entry;
    if(!readable(component,0xa30)) return -1;
    double scale[3]; memcpy(scale,entry+0x50,sizeof(scale));
    int before=growing->count;
    /* Native growth advances its cursor before processing one record. Target
     * this record through all stages, then revisit the compacted index. */
    *(int32_t *)(ctx->region+0xf78)=index-1;
    *(int32_t *)(entry+0x70)=-30000;
    void (*grow)(void *)=(void *)(ctx->base+0x4c44260);
    grow(ctx->region);
    if(!array_valid(growing)) return -1;
    if(growing->count<before) return 1;
    entry=growing->data+(size_t)index*128;
    return component!=*(void **)entry || memcmp(scale,entry+0x50,sizeof(scale))!=0;
}
__declspec(dllexport) int mobs_forestry_run(void *unused) {
    (void)unused;
    char path[MAX_PATH], request[MAX_PATH], response[MAX_PATH];
    GetModuleFileNameA(self_module,path,MAX_PATH);
    char *slash=strrchr(path,'\\'); if (!slash) return 0; slash[1]=0;
    snprintf(request,sizeof(request),"%sforestry.request",path);
    snprintf(response,sizeof(response),"%sforestry.response",path);
    FILE *in=fopen(request,"r"), *out=fopen(response,"w");
    if (!out) { if(in) fclose(in); return 0; }
    unsigned long long region_address=0,pawn_address=0,component_address=0;
    int mode=0, preview=1,cursor=0,next_index=0;
    Tree *untracked=NULL;
    Vec at={0};
    double area_x=0,area_y=0,area_radius=0;
    if (!in || fscanf(in,"MOBS_FORESTRY_1 %d %d %llu %llu %llu %lf %lf %lf",
        &mode,&preview,&region_address,&pawn_address,&component_address,&at.x,&at.y,&at.z)!=8) {
        fprintf(out,"ERROR Invalid forestry request\n"); goto finish;
    }
    /* Optional continuation cursor; old requests start at the first tree. */
    if(fscanf(in,"%d",&cursor)!=1) cursor=0;
    if(mode==5 || mode==6) {
        if(fscanf(in,"%lf %lf %lf",&area_x,&area_y,&area_radius)!=3 || !isfinite(area_x) ||
            !isfinite(area_y) || !isfinite(area_radius) || area_radius<=0 || area_radius>25000) {
            fprintf(out,"ERROR Invalid tree work area\n"); goto finish;
        }
    }
    if(cursor<0 || cursor>50000) { fprintf(out,"ERROR Invalid forestry continuation\n"); goto finish; }
    unsigned char *base=(unsigned char*)GetModuleHandleA(NULL);
    IMAGE_DOS_HEADER *dos=(IMAGE_DOS_HEADER*)base;
    IMAGE_NT_HEADERS64 *pe=(IMAGE_NT_HEADERS64*)(base+dos->e_lfanew);
    const unsigned char grow_sig[]={0x4c,0x8b,0xdc,0x55,0x57,0x41,0x54,0x49,0x8d,0xab,0x98,0xfe,0xff,0xff};
    const unsigned char check_sig[]={0x48,0x89,0x5c,0x24,0x10,0x48,0x89,0x6c,0x24,0x18};
    const unsigned char entry_sig[]={0x48,0xc7,0x01,0,0,0,0,0x48,0x8b,0xc1};
    const unsigned char transform_sig[]={0x48,0x89,0x5c,0x24,0x20,0x55,0x56,0x57};
    const unsigned char reserve_sig[]={0x48,0x89,0x5c,0x24,0x08,0x48,0x89,0x74,0x24,0x10};
    if (pe->FileHeader.TimeDateStamp!=0x6836c1ba || pe->OptionalHeader.SizeOfImage!=0x9dfd000 ||
        !signature(base,0x4c44260,grow_sig,sizeof(grow_sig)) ||
        !signature(base,0x4c66bf0,check_sig,sizeof(check_sig)) ||
        !signature(base,0x4da0330,entry_sig,sizeof(entry_sig)) ||
        !signature(base,0x39769b0,transform_sig,sizeof(transform_sig)) ||
        !signature(base,0x4b21260,reserve_sig,sizeof(reserve_sig))) {
        fprintf(out,"ERROR Unsupported game binary; forestry refused\n"); goto finish;
    }
    unsigned char *region=(unsigned char*)(uintptr_t)region_address;
    if (mode<0 || mode>6 || (preview!=0 && preview!=1) || !readable(region,0x1038) ||
        *(uintptr_t*)(region+0x350)!=(uintptr_t)pawn_address) {
        fprintf(out,"ERROR Invalid or foreign region\n"); goto finish;
    }
    Array *growing=(Array*)(region+0xf68);
    if (!array_valid(growing)) { fprintf(out,"ERROR Invalid growing-tree array\n"); goto finish; }
    int before=growing->count, planted=0, eligible=0, steps=0,enrolled=0,completed=0,blocked=0;
    if(mode==0 || mode==2) {
        untracked=HeapAlloc(GetProcessHeap(),0,50000*sizeof(Tree));
        if(!untracked || !collect_untracked(base,region,growing,untracked,&enrolled)) {
            fprintf(out,"ERROR Cannot safely enumerate young tree stages (limit 50000); no changes\n"); goto finish;
        }
        if(!preview) for(int i=0;i<enrolled;i++) {
            if(!append_tree(base,growing,untracked[i].component,&untracked[i].transform)) {
                fprintf(out,"ERROR Cannot register remaining young trees; stopped\n"); goto finish;
            }
        }
    }
    if (mode==1 || mode==2) {
        unsigned char *component=(unsigned char*)(uintptr_t)component_address;
        float clearance=350.0f;
        int (*can_plant)(void*,Vec*,float*,unsigned char)=(void*)(base+0x4c66bf0);
        if (!readable(component,0xa30) || !isfinite(at.x) || !isfinite(at.y) || !isfinite(at.z)) {
            fprintf(out,"ERROR Invalid planting component or location\n"); goto finish;
        }
        eligible=can_plant(region,&at,&clearance,1)!=0;
        if (eligible && !preview) {
            Transform transform={0}; transform.values[3]=1;
            transform.values[4]=at.x; transform.values[5]=at.y; transform.values[6]=at.z;
            transform.values[8]=transform.values[9]=transform.values[10]=0.25;
            uintptr_t *vtable=*(uintptr_t**)component;
            if (!readable(vtable,0xb28) || vtable[0xb20/8]<(uintptr_t)base ||
                vtable[0xb20/8]>=(uintptr_t)base+pe->OptionalHeader.SizeOfImage) {
                fprintf(out,"ERROR Unexpected foliage virtual method\n"); goto finish;
            }
            /* Same insertion and persistent record constructor used by foresters.
             * Reserve first, so allocation failure cannot leave a visual-only tree. */
            int index=growing->count;
            if (index==growing->capacity) {
                void (*reserve)(Array*,int)=(void*)(base+0x4b21260);
                growing->count=index+1; reserve(growing,index); growing->count=index;
            }
            if (!readable(growing->data,(size_t)(index+1)*128)) {
                fprintf(out,"ERROR Cannot reserve native tree record\n"); goto finish;
            }
            int (*add_instance)(void*,Transform*,unsigned char)=(void*)vtable[0xb20/8];
            int instance=add_instance(component,&transform,1);
            if (instance<0) { fprintf(out,"ERROR Native foliage insertion refused\n"); goto finish; }
            void (*construct)(void*,void*,Transform*,int)=(void*)(base+0x4da0330);
            construct(growing->data+(size_t)index*128,component,&transform,-1);
            growing->count=index+1; planted=1;
        }
    }
    if(mode>=4 && preview) {
        for(int i=0;i<growing->count;i++) {
            double *position=(double *)(growing->data+(size_t)i*128+0x30);
            double x=position[0]-area_x,y=position[1]-area_y;
            if(mode==4 || x*x+y*y<=area_radius*area_radius) eligible++;
        }
    }
    if ((mode==0 || mode==2 || mode>=3) && !preview) {
        GrowthContext ctx={base,region,growing,mode==5 || mode==6,area_x,area_y,area_radius};
        ForestryOps ops={&ctx,growth_count,advance_tree};
        ForestryResult result={0};
        if(mode==4 || mode==5) {
            int index=cursor;
            while(index<growing->count && result.steps<500) {
                int before_count=growing->count;
                int progress=advance_tree(&ctx,index);
                result.steps++;
                if(progress<0) { result.error=1; break; }
                if(growing->count<before_count) result.completed+=before_count-growing->count;
                else index++;
            }
            result.next_index=index;
        } else result=forestry_finish(ops,500,cursor);
        if(result.error) { fprintf(out,"ERROR Tree state changed unexpectedly; stopped\n"); goto finish; }
        completed=result.completed; blocked=result.blocked; steps=result.steps; next_index=result.next_index;
    }
    fprintf(out,"OK %d %d %d %d %d %d %d %d %d\n",before,planted,growing->count,eligible,steps,enrolled,completed,blocked,next_index);
finish:
    if(untracked) HeapFree(GetProcessHeap(),0,untracked);
    if (in) fclose(in);
    fclose(out);
    return 0;
}
BOOL WINAPI DllMain(HINSTANCE module,DWORD reason,LPVOID reserved) {
    (void)reserved; if(reason==DLL_PROCESS_ATTACH) self_module=module; return TRUE;
}
