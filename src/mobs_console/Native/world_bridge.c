/* Copyright 2026 Mobs. MIT licensed. Independent 0.8.117 world adapter.
 * Uses the game's registered resource/node factories and depletion removal path.
 * ResourceNodeData stride 0x80 (GetProperties 0x4adc410), properties start +8.
 * SpawnResource 0x4ce5780 takes Region and FTransform, NOT a bare FVector.
 */
#include <windows.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <wchar.h>
#include "world_layout.h"
#include "world_plan.h"
#include <stddef.h>
typedef unsigned char Byte;
typedef struct { void *data; int32_t count,capacity; } Array;
typedef struct { double x,y,z; } Vec;
typedef struct __attribute__((aligned(16))) { double q[4],pos[4],scale[4]; } Transform;
typedef struct { int type,amount; Byte rest[16]; } Good;
_Static_assert(sizeof(Transform)==0x60 && offsetof(Transform,pos)==0x20, "FTransform layout");
_Static_assert(sizeof(Good)==0x18 && sizeof(Array)==0x10, "Native container layout");
static HMODULE module;
static Byte *base;
#define FN(rva,type) ((type)(base+(rva)))
#define PTR(p,o) (*(Byte **)((Byte *)(p)+(o)))
#define INT(p,o) (*(int *)((Byte *)(p)+(o)))
static int readable(const void *p,size_t n) {
    MEMORY_BASIC_INFORMATION m;
    if(!p || !VirtualQuery(p,&m,sizeof(m)) || m.State!=MEM_COMMIT || (m.Protect&(PAGE_NOACCESS|PAGE_GUARD))) return 0;
    return (uintptr_t)p+n>=(uintptr_t)p && (uintptr_t)p+n<=(uintptr_t)m.BaseAddress+m.RegionSize;
}
static int object(Byte *p,size_t n) { return readable(p,n) && !(INT(p,8)&0x60000000); }
static int array(Array *a,int max,size_t stride) {
    return readable(a,sizeof(*a)) && a->count>=0 && a->count<=max && a->capacity>=a->count && a->capacity<=max*2 &&
        (!a->count || readable(a->data,(size_t)a->count*stride));
}
static int finite_vec(Vec p) { return isfinite(p.x)&&isfinite(p.y)&&isfinite(p.z)&&fabs(p.x)<1e7&&fabs(p.y)<1e7&&fabs(p.z)<1e7; }
static int position(Byte *actor,Vec *p) {
    if(!object(actor,0x1c0) || !readable(PTR(actor,0x1b8),0x208)) return 0;
    memcpy(p,PTR(actor,0x1b8)+0x1f0,sizeof(*p));return finite_vec(*p);
}
static double distance(Vec a,Vec b) { return (a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y); }
static int supported(int kind) { return kind==1||kind==2||kind==3||kind==5||kind==6||kind==7||kind==9||kind==11; }
static int registered(Array *a,void *p) {
    if(!array(a,100000,8)) return 0;
    for(int i=0;i<a->count;i++) if(((void **)a->data)[i]==p) return 1;
    return 0;
}
static void erase_pointer(Array *a,void *p) {
    int n=0;
    for(int i=0;i<a->count;i++) if(((void **)a->data)[i]!=p) ((void **)a->data)[n++]=((void **)a->data)[i];
    a->count=n;
}
static void append_pointer(Array *a,void *p) {
    int index=a->count++;
    if(a->count>a->capacity) FN(0x4718f10,void(*)(Array *,int))(a,index);
    ((void **)a->data)[index]=p;
}
static Transform transform(Vec pos) {
    Transform t={0};t.q[3]=1;t.pos[0]=pos.x;t.pos[1]=pos.y;t.pos[2]=pos.z;
    t.scale[0]=t.scale[1]=t.scale[2]=1;return t;
}
static Byte *properties(Byte *settings,int kind) {
    Array *rows=(Array *)(settings+0x68);
    if(!array(rows,256,0x80)) return NULL;
    for(int i=0;i<rows->count;i++) {
        Byte *row=(Byte *)rows->data+i*0x80;
        if(INT(row,0)==kind) return row+8;
    }
    return NULL;
}
static void destroy(Byte *actor) { FN(0x34bf200,int(*)(Byte *,int,int))(actor,0,1); }
static Byte *spawn_node(Byte *engine,int kind,Vec pos,int rich,Array *clumps) {
    return FN(0x4ce6620,Byte *(*)(Byte *,int,Vec *,int,Array *,int))(engine,kind,&pos,rich,clumps,0);
}
static void refresh_rich(Byte *settings,Byte *props,Byte *node,int rich) {
    node[0x2ac]=(Byte)rich;
    FN(0x4cdc0b0,void(*)(Byte *))(node);
    Byte *decal=PTR(node,0x2e0),*material=PTR(props,rich?0x58:0x50);
    float radius=*(float *)(settings+(rich?0x48:0x44));
    if(object(decal,0x278) && object(material,0x28) && isfinite(radius) && radius>0 && radius<100000) {
        double *size=(double *)(decal+0x258);size[0]=25000;size[1]=size[2]=radius*2;
        FN(0x375e190,void(*)(Byte *,Byte *))(decal,material);
        FN(0x37aaa30,void(*)(Byte *))(decal);
        FN(0x37a9c60,void(*)(Byte *,int,int))(decal,0,1);
    }
    Byte *tree=PTR(PTR(node,0x2b0),0x738);
    if(tree) {
        FN(0x4ba40c0,void(*)(Byte *,Byte *))(tree,node);
        FN(0x4ba4120,void(*)(Byte *,Byte *))(tree,node);
    }
}
static int instant_build(Byte *engine,int wanted,int preview,FILE *out) {
    Array *flags=(Array *)(engine+0x1098);
    if(!array(flags,1024,sizeof(Array))) return 0;
    Array *strings=flags->data;
    int found=0;
    for(int i=0;i<flags->count;i++) {
        if(!array(strings+i,1024,2)) return 0;
        if(strings[i].count==11 && !wmemcmp(strings[i].data,L"instaBuild",11)) found++;
    }
    if(!preview && wanted!=2) {
        if(wanted && !found) {
            Array text={0};FN(0x10cd540,void(*)(Array *,const wchar_t *))(&text,L"instaBuild");
            if(!array(&text,1024,2) || text.count!=11) return 0;
            int index=flags->count;
            if(index==flags->capacity) {
                FN(0x10dd360,void(*)(void **,int,int,size_t))(&flags->data,index,index+1,16);
                flags->capacity=index+1;
            }
            ((Array *)flags->data)[index]=text;flags->count++;found=1;
        } else if(!wanted && found) {
            int n=0;
            for(int i=0;i<flags->count;i++) {
                if(strings[i].count==11 && !wmemcmp(strings[i].data,L"instaBuild",11))
                    FN(0x1128900,void(*)(void *))(strings[i].data);
                else strings[n++]=strings[i];
            }
            flags->count=n;found=0;
        }
    }
    fprintf(out,"OK %sNative instant build %s. Applies to newly placed buildings globally this session; existing sites use mobs.finish_constructions.\n",
        preview && wanted!=2?"Preview: would set ":"",wanted==2?(found?"on":"off"):(wanted?"on":"off"));
    return 1;
}
__declspec(dllexport) int mobs_world_run(void *unused) {
    (void)unused;
    char path[MAX_PATH],request[MAX_PATH],response[MAX_PATH];
    GetModuleFileNameA(module,path,MAX_PATH);char *slash=strrchr(path,'\\');if(!slash) return 0;slash[1]=0;
    snprintf(request,sizeof(request),"%sworld.request",path);snprintf(response,sizeof(response),"%sworld.response",path);
    FILE *in=fopen(request,"r"),*out=fopen(response,"w");if(!out) { if(in) fclose(in);return 0; }
    unsigned long long ea=0,pa=0,ra=0,ta=0;
    int mode=0,kind=0,amount=0,count=0,rich=0,preview=1;Vec pos={0};
    const char *error="Invalid world request";
    if(!in || fscanf(in,"MOBS_WORLD_1 %llu %llu %llu %d %d %d %d %d %d %lf %lf %lf %llu",
        &ea,&pa,&ra,&mode,&kind,&amount,&count,&rich,&preview,&pos.x,&pos.y,&pos.z,&ta)!=13 ||
        mode<1||mode>9||(!supported(kind)&&kind!=0)||amount<0||amount>1000000||count<0||count>64||rich<0||rich>2||
        preview<0||preview>1||!finite_vec(pos)) goto fail;
    base=(Byte *)GetModuleHandleA(NULL);
    IMAGE_DOS_HEADER *dos=(IMAGE_DOS_HEADER *)base;
    IMAGE_NT_HEADERS64 *pe=(IMAGE_NT_HEADERS64 *)(base+dos->e_lfanew);
    error="Unsupported game binary; world edit refused";
    if(pe->FileHeader.TimeDateStamp!=0x6836c1ba||pe->OptionalHeader.SizeOfImage!=0x9dfd000) goto fail;
    for(size_t i=0;i<sizeof(WORLD_SIGNATURES)/sizeof(WORLD_SIGNATURES[0]);i++) {
        const WorldSignature *signature=WORLD_SIGNATURES+i;
        if(memcmp(base+signature->rva,signature->bytes,sizeof(signature->bytes))) goto fail;
    }
    Byte *engine=(Byte *)(uintptr_t)ea,*pawn=(Byte *)(uintptr_t)pa,*region=(Byte *)(uintptr_t)ra;
    error="Invalid simulation or player";
    if(!object(engine,0x1470)||!object(pawn,0x348)||PTR(pawn,0x340)!=engine) goto fail;
    if(mode==7) { error="Unexpected native instant-build flag layout";if(!instant_build(engine,rich,preview,out)) goto fail;goto finish; }
    error=mode==8?"Bandit camps require an unclaimed region":"Click inside a region owned by your lord";
    if(!object(region,0xcd0)||(mode==8?PTR(region,0x350)!=NULL:PTR(region,0x350)!=pawn)||
        FN(0x4cc9ab0,Byte *(*)(Byte *,Vec *,int))(engine,&pos,0)!=region) goto fail;
    if(mode==8) {
        error="Bandit camps require unclaimed ground and valid squad registries";
        Array *bandits=(Array *)(engine+0x448);
        Byte *component=PTR(engine,0x2d0);
        if(!array(bandits,100000,8)||!object(component,0x148)) goto fail;
        if(preview) { fprintf(out,"OK Preview: register a bandit camp squad here in this unclaimed region; nothing changed.\n");goto finish; }
        Byte *owner=FN(0x4c88b80,Byte *(*)(Byte *,Vec *))(engine,&pos);
        error="Native bandit faction unavailable";if(!object(owner,0x12f0)||!owner[0xb80]) goto fail;
        Array *camps=(Array *)(owner+0x11c0);if(!array(camps,10000,4)) goto fail;
        uint64_t name=0;FN(0x1251260,uint64_t *(*)(uint64_t *,const wchar_t *,int))(&name,L"brigands",1);
        Vec rotation={0};int id=-1;
        FN(0x4ce1b40,int *(*)(Byte *,int *,uint64_t *,Vec *,Vec *,Byte *,int,int))(engine,&id,&name,&pos,&rotation,owner,-1,0);
        Byte *squad=FN(0x4d63100,Byte *(*)(Byte *,int))(component,id);
        error="Native camp squad spawn failed";if(id<0||!readable(squad,0x400)) goto fail;
        Array *units=(Array *)(squad+0x18);
        error="Native camp unit registry invalid";if(!array(units,1000,8)||!units->count) goto fail;
        squad[0x10]=4;PTR(squad,0x1e8)=region;PTR(squad,0x1f0)=region;
        FN(0x4d83ac0,void(*)(Byte *,int,int,int,int))(component,INT(squad,0x64),14,1,0);
        memcpy(squad+0xb8,&pos,sizeof(pos));
        for(int i=0;i<units->count;i++) {
            Byte *unit=((Byte **)units->data)[i];
            if(!registered(bandits,unit)) append_pointer(bandits,unit);
        }
        int index=camps->count++;
        if(camps->count>camps->capacity) FN(0x4b219e0,void(*)(Array *,int))(camps,index);
        ((int *)camps->data)[index]=id;squad[0x338]=1;
        fprintf(out,"OK Registered bandit camp squad %d and requested its native camp order at the click. Resume simulation to build the camp. No undo.\n",id);goto finish;
    }
    Array *nodes=(Array *)(engine+0x6e8),*deposits=(Array *)(engine+0x7b8),*resources=(Array *)(region+0xcc0);
    error="Invalid region resource registry";
    if(!array(nodes,100000,8)||!array(deposits,100000,8)||!array(resources,100000,8)) goto fail;
    Byte *settings_class=FN(0x4adace0,Byte *(*)(void))();
    Byte *settings=object(settings_class,0x118)?PTR(settings_class,0x110):NULL;
    error="Resource settings are not loaded";if(!object(settings,0x80)) goto fail;
    Byte *props=kind?properties(settings,kind):NULL;
    if(mode==1||mode==6) {
        error="Resource template or capacity unavailable";
        if(!props||!supported(kind)||!object(PTR(props,0x30),0x40)||count<1) goto fail;
        int capacity=amount?amount:INT(props,rich?0x18:0x10);
        if(capacity<1||capacity>1000000||INT(props,4)<1||INT(props,4)>10000) goto fail;
        Byte *pond=(Byte *)(uintptr_t)ta;
        Array *pond_resources=NULL;
        if(mode==6) {
            error="Pond changed or already has a fish shoal; use mobs.refill_resources fish";
            if(!object(pond,0x3d0)||PTR(pond,0x2c8)!=region||PTR(pond,0x2e8)!=engine) goto fail;
            pond_resources=(Array *)(pond+0x308);if(!array(pond_resources,10000,8)) goto fail;
            for(int i=0;i<resources->count;i++) {
                Byte *res=((Byte **)resources->data)[i];
                if(object(res,0x318)&&PTR(res,0x2d8)==pond&&INT(res,0x30c)==INT(props,4)) goto fail;
            }
        }
        Vec places[64];
        for(int i=0;i<count;i++) {
            places[i]=pos;
            if(count>1) { double angle=i*2.399963229728653;double radius=160.0*sqrt((double)i);places[i].x+=cos(angle)*radius;places[i].y+=sin(angle)*radius; }
            error="Resource cluster crosses the region boundary";
            if(FN(0x4cc9ab0,Byte *(*)(Byte *,Vec *,int))(engine,&places[i],0)!=region) goto fail;
            if(kind!=5&&kind!=11) places[i].z=FN(0x4cee3d0,float(*)(Byte *,Vec *,int,int,int))(engine,&places[i],0,0,-1);
            error="Terrain height invalid";if(!finite_vec(places[i])) goto fail;
        }
        if(preview) { fprintf(out,"OK Preview: create %d clump(s), %d units each, %s group; nothing changed.\n",count,capacity,rich?"rich":"normal");goto finish; }
        Array resource_name={0};uint64_t name=0;
        FN(0x4c76400,Array *(*)(Array *,int))(&resource_name,kind);
        error="Cannot resolve native resource name";
        if(!array(&resource_name,256,2)||resource_name.count<2) { if(resource_name.data) FN(0x1128900,void(*)(void *))(resource_name.data);goto fail; }
        FN(0x1251260,uint64_t *(*)(uint64_t *,const wchar_t *,int))(&name,resource_name.data,1);
        FN(0x1128900,void(*)(void *))(resource_name.data);
        Byte *created[64]={0};Array clumps={created,0,64};
        for(int i=0;i<count;i++) {
            Transform t=transform(places[i]);Byte *template=PTR(props,0x30);
            Byte *res=FN(0x4ce5780,Byte *(*)(Byte *,Byte *,Transform *,Byte **,int))(engine,region,&t,&template,0);
            if(!object(res,0x330)) break;
            *(uint64_t *)(res+0x2f0)=name;INT(res,0x308)=capacity;INT(res,0x310)=capacity;INT(res,0x30c)=INT(props,4);
            created[clumps.count++]=res;
        }
        Byte *node=clumps.count?spawn_node(engine,kind,pos,rich,&clumps):NULL;
        if(!object(node,0x318)) {
            for(int i=0;i<clumps.count;i++) FN(0x4cacc00,void(*)(Byte *,Byte *))(engine,created[i]);
            error="Game refused the resource group; created clumps removed";goto fail;
        }
        if(pond_resources) { PTR(created[0],0x2d8)=pond;append_pointer(pond_resources,created[0]); }
        fprintf(out,"OK Created %d/%d registered clump(s), %d units each. No undo.\n",clumps.count,count,capacity);goto finish;
    }
    if(mode==2||mode==3||mode==9) {
        Byte *nearest=NULL,*closest=NULL;double best=2500.0*2500;
        for(int i=0;i<nodes->count;i++) {
            Byte *node=((Byte **)nodes->data)[i];
            if(!object(node,0x318)||PTR(node,0x2b0)!=region||!supported(INT(node,0x2a8))||(kind&&INT(node,0x2a8)!=kind)) continue;
            Array *clumps=(Array *)(node+0x2c0);if(!array(clumps,10000,8)) continue;
            for(int j=0;j<clumps->count;j++) {
                Byte *res=((Byte **)clumps->data)[j];Vec p;
                if(!object(res,0x330)||PTR(res,0x2b8)!=node||PTR(res,0x2d0)!=region||!position(res,&p)) continue;
                double d=distance(pos,p);if(d<best) { nearest=node;closest=res;best=d; }
            }
        }
        error="No matching owned surface resource within 2500 game units";if(!nearest) goto fail;
        Array *clumps=(Array *)(nearest+0x2c0);Byte *targets[10000];int n=(count==1&&mode==3)||mode==9?1:clumps->count;
        if(n==1&&((count==1&&mode==3)||mode==9)) targets[0]=closest;else memcpy(targets,clumps->data,(size_t)n*8);
        props=properties(settings,INT(nearest,0x2a8));error="Resource properties unavailable";if(!props) goto fail;
        for(int i=0;i<n;i++) {
            Byte *res=targets[i];error="Resource group contains an invalid or attached clump; no changes";
            if(!object(res,0x330)||PTR(res,0x2b8)!=nearest||PTR(res,0x2d0)!=region||PTR(res,0x2d8)) goto fail;
            if(mode==2 && (INT(res,0x310)<1||INT(res,0x310)>1000000||INT(res,0x308)<0||INT(res,0x308)>INT(res,0x310))) goto fail;
        }
        if(mode==9) {
            Byte *res=targets[0];int before=INT(res,0x308),capacity=INT(res,0x310),after=0,next_capacity=0;
            error="Invalid resource amount or resulting total exceeds one million";
            if(!world_add_amount(before,capacity,amount,&after,&next_capacity)) goto fail;
            if(!preview) { INT(res,0x308)=after;INT(res,0x310)=next_capacity; }
            fprintf(out,"OK %sResource amount %d -> %d in the nearest clump; capacity grows if needed. %s\n",
                preview?"Preview: ":"",before,after,preview?"Nothing changed.":"No undo.");goto finish;
        }
        int capacity=INT(props,rich?0x18:0x10);
        error="Invalid native richness capacity";if(mode==2&&(capacity<1||capacity>1000000)) goto fail;
        if(preview) { fprintf(out,"OK Preview: %s %d clump(s); nothing changed.\n",mode==2?(rich?"mark rich":"mark normal"):"remove",n);goto finish; }
        if(mode==2) {
            for(int i=0;i<n;i++) { Byte *res=targets[i];int after=0;world_rich_amount(INT(res,0x308),INT(res,0x310),capacity,&after);INT(res,0x308)=after;INT(res,0x310)=capacity; }
            refresh_rich(settings,props,nearest,rich);
        } else {
            for(int i=0;i<n;i++) FN(0x4cacc00,void(*)(Byte *,Byte *))(engine,targets[i]);
            if(count==0&&registered(nodes,nearest)) FN(0x4cad090,void(*)(Byte *,Byte *))(engine,nearest);
        }
        fprintf(out,"OK %s %d clump(s). No undo.\n",mode==2?(rich?"Marked rich":"Marked normal"):"Removed",n);goto finish;
    }
    if(mode==4) {
        error="Choose iron, clay or salt and a positive amount";
        if((kind!=1&&kind!=2&&kind!=3)||amount<1) goto fail;
        if(preview) { fprintf(out,"OK Preview: create underground deposit with %d units and a map node; nothing changed.\n",amount);goto finish; }
        Good good={0};good.type=kind==1?145:kind==2?14:146;good.amount=amount;
        Transform t=transform(pos);
        Byte *decal=FN(0x4ce2b30,Byte *(*)(Byte *,Good *,Transform *,int,int,int))(engine,&good,&t,0,-1,rich);
        error="Game refused underground deposit";if(!object(decal,0x2d8)||!registered(deposits,decal)) goto fail;
        Array empty={0};Byte *node=spawn_node(engine,kind,pos,rich,&empty);
        if(!object(node,0x318)) { /* Roll back the new decal if its map node failed. */
            Byte *tree=PTR(region,0x738);if(tree) FN(0x4ba40c0,void(*)(Byte *,Byte *))(tree,decal);
            erase_pointer(deposits,decal);destroy(decal);error="Map node creation failed; new underground deposit removed";goto fail;
        }
        fprintf(out,"OK Created registered underground deposit (%d units) and map node. No undo.\n",amount);goto finish;
    }
    if(mode==5) {
        Byte *nearest=NULL;double best=2500.0*2500;
        int good_type=kind==1?145:kind==2?14:kind==3?146:0;
        for(int i=0;i<deposits->count;i++) {
            Byte *deposit=((Byte **)deposits->data)[i];Vec p;
            if(!object(deposit,0x2d8)||(good_type&&INT(deposit,0x2b0)!=good_type)||!position(deposit,&p)||
                FN(0x4cc9ab0,Byte *(*)(Byte *,Vec *,int))(engine,&p,0)!=region) continue;
            double d=distance(pos,p);if(d<best) { nearest=deposit;best=d; }
        }
        error="No matching owned underground deposit within 2500 game units";if(!nearest) goto fail;
        if(preview) { fprintf(out,"OK Preview: remove nearest underground deposit/decal (%d units); surface clumps remain.\n",INT(nearest,0x2b4));goto finish; }
        Byte *tree=PTR(region,0x738);if(tree) FN(0x4ba40c0,void(*)(Byte *,Byte *))(tree,nearest);
        erase_pointer(deposits,nearest);destroy(nearest);
        fprintf(out,"OK Removed underground deposit/decal. Surface groups remain; use mobs.resource remove if desired. No undo.\n");goto finish;
    }
fail:
    fprintf(out,"ERROR %s\n",error);
finish:
    if(in) fclose(in);
    fclose(out);return 0;
}
BOOL WINAPI DllMain(HINSTANCE instance,DWORD reason,LPVOID reserved) { (void)reserved;if(reason==DLL_PROCESS_ATTACH) module=instance;return TRUE; }
