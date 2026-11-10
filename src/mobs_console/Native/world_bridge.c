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
static const char *resource_kind_name(int kind) {
    switch(kind) {
        case 1:return "salt";case 2:return "iron";case 3:return "clay";case 4:return "deer";case 5:return "fish";
        case 6:return "berries";case 7:return "stone";case 9:return "mushrooms";case 11:return "eel";
        case 10:return "hare";
        default:return "all";
    }
}
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
static int sync_resource_hud(Byte *engine,Byte *pawn,int preview,int *before,int *after) {
    Array *nodes=(Array *)(engine+0x6e8);
    if(!array(nodes,100000,8)) return 0;
    for(int i=0;i<nodes->count;i++)
        if(!object(((Byte **)nodes->data)[i],0x318)) return 0;
    Byte *controller=FN(0x38cabd0,Byte *(*)(Byte *,int))(pawn,0);
    if(!object(controller,0x360)) return 0;
    Byte *hud=PTR(controller,0x358);
    /* HudCPP owns a separate FTickable resource snapshot at +0x5c8/+0x5d0.
     * Its BeginPlay copies the world list once. Do not call BeginPlay again:
     * synchronize only that array, on the game thread used by our commands. */
    if(!object(hud,0x5e0)||PTR(hud,0x5c8)!=base+0x7ebbed0) return 0;
    Array *displayed=(Array *)(hud+0x5d0);
    if(!array(displayed,100000,8)||(nodes->data&&displayed->data==nodes->data)) return 0;
    *before=displayed->count;*after=nodes->count;
    if(preview) return 1;
    while(displayed->capacity<nodes->count) append_pointer(displayed,NULL);
    if(!world_copy_nodes(displayed->data,displayed->capacity,nodes->data,nodes->count)) return 0;
    displayed->count=nodes->count;
    return 1;
}
static int sync_resource_view(Byte *node,Byte *pawn) {
    if(!object(node,0x318)||!object(PTR(node,0x2d0),0x278)||!object(PTR(node,0x2e0),0x278)) return 0;
    Array *clumps=(Array *)(node+0x2c0);
    if(!array(clumps,10000,8)) return 0;
    for(int i=0;i<clumps->count;i++) {
        Byte *res=((Byte **)clumps->data)[i];
        if(!object(res,0x330)||!object(PTR(res,0x2a8),0x278)) return 0;
    }
    /* A new node did not receive earlier paper-map view broadcasts. Apply the
     * current view to both decals and all clump meshes through the game handler. */
    FN(0x4cd4390,void(*)(Byte *,int))(node,pawn[0xb20]!=0);
    return 1;
}
static Byte *spawn_node(Byte *engine,int kind,Vec pos,int rich,Array *clumps) {
    return FN(0x4ce6620,Byte *(*)(Byte *,int,Vec *,int,Array *,int))(engine,kind,&pos,rich,clumps,0);
}
/* Native eel generation updates AActor::Tags on Region (verified offset 0x1e0).
 * Gameplay/UI use availability tags separately from the spatial node registry.
 * Adding a second kind must not remove Fish or another existing region tag. */
static int ensure_region_kind(Byte *region,int kind,int preview,int *added) {
    Array *tags=(Array *)(region+0x1e0),text={0};uint64_t name=0;
    if(!array(tags,256,8)||tags->count>=256) return 0;
    FN(0x4c76400,Array *(*)(Array *,int))(&text,kind);
    if(!array(&text,256,2)||text.count<2) {
        if(text.data) FN(0x1128900,void(*)(void *))(text.data);
        return 0;
    }
    FN(0x1251260,uint64_t *(*)(uint64_t *,const wchar_t *,int))(&name,text.data,1);
    FN(0x1128900,void(*)(void *))(text.data);
    if(!(uint32_t)name) return 0;
    *added=1;
    for(int i=0;i<tags->count;i++) if(((uint64_t *)tags->data)[i]==name) { *added=0;return 1; }
    if(preview) return 1;
    int index=tags->count++;
    if(tags->count>tags->capacity) FN(0x10ddd10,void(*)(Array *,int))(tags,index);
    ((uint64_t *)tags->data)[index]=name;
    return 1;
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
/* Empty legacy map markers have no clump to pass to the depletion path.
 * Remove only an owned, clumpless, non-wildlife node selected by the caller. */
static void remove_empty_node(Byte *engine,Byte *node) {
    /* Native node retirement also clears its HUD selection/hover state. */
    FN(0x4cad090,void(*)(Byte *,Byte *))(engine,node);
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
        mode<1||mode>14||(!supported(kind)&&kind!=0&&!(mode==12&&(kind==4||kind==10)))||amount<0||amount>1000000||count<0||count>64||rich<0||rich>2||
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
    if(!object(engine,0x1470)||!object(pawn,0xb21)||PTR(pawn,0x340)!=engine||pawn[0xb20]>1) goto fail;
    if(mode==7) { error="Unexpected native instant-build flag layout";if(!instant_build(engine,rich,preview,out)) goto fail;goto finish; }
    if(mode==11) {
        int before=0,after=0;
        error="HUD resource snapshot unavailable; load a settlement and retry";
        if(!sync_resource_hud(engine,pawn,preview,&before,&after)) goto fail;
        fprintf(out,"OK %sHUD resource list %d -> %d nodes. %s Resource quantities unchanged.\n",
            preview?"Preview: would synchronize ":"Synchronized ",before,after,
            preview?"Nothing changed.":"Normal icons and hover details update on the next HUD tick.");goto finish;
    }
    error=mode==8?"Bandit camps require an unclaimed region":"Click inside a region owned by your lord";
    if(!object(region,0xcd0)||(mode==8?PTR(region,0x350)!=NULL:PTR(region,0x350)!=pawn)||
        (mode!=14&&FN(0x4cc9ab0,Byte *(*)(Byte *,Vec *,int))(engine,&pos,0)!=region)) goto fail;
    if(mode==14) {
        /* Explicit resident creation bypasses the scheduling/approval gates in
         * growPopulation; it never calls the daily emigration/age update loop. */
        Byte *home=(Byte *)(uintptr_t)ta;
        Array *families=(Array *)(region+0x4e8),*residents=(Array *)(region+0x368);
        int family_id=amount-1;
        error="Population target/home is invalid or not usable; nothing changed";
        if(kind<0||kind>2||!object(region,0x1290)||PTR(region,0x318)!=engine||!region[0x2e8]||
            !array(families,100000,0x50)||!array(residents,100000,8)||
            !object(home,0x1044)||PTR(home,0x2c8)!=region||PTR(home,0x2e8)!=engine||
            home[0x3cc]!=1||!home[0x3c1]||home[0x700]||INT(home,0xf20)>0||
            !registered((Array *)(region+0x658),home)) goto fail;
        Vec entrance;memcpy(&entrance,home+0x3f8,sizeof(entrance));
        error="House entrance is blocked; nothing changed";
        if(!finite_vec(entrance)||!readable(PTR(engine,0x2c0),0x450)||
            FN(0x4c8e610,Byte(*)(Byte *,Vec *))(engine,&entrance)) goto fail;
        if(family_id<0) {
            error="New families require a vacant home and no homeless families; nothing changed";
            if(kind!=0||families->count>=100000||residents->count>=100000) goto fail;
            int occupied=0;
            for(int i=0;i<families->count;i++) {
                Byte *family=(Byte *)families->data+i*0x50;
                Byte *existing_home=PTR(family,0x20);
                if(!object(existing_home,0x3cd)||existing_home[0x3cc]==7) goto fail;
                if(existing_home==home) occupied++;
            }
            int maximum=FN(0x4d406c0,int(*)(Byte *))(home);
            if(maximum<1||maximum>64||occupied>=maximum||INT(home,0x1040)>=maximum) goto fail;
        } else {
            error="Family changed, is full, or already has this role; nothing changed";
            if(family_id>=families->count) goto fail;
            Byte *family=(Byte *)families->data+family_id*0x50;
            Array *members=(Array *)family;
            if(PTR(family,0x20)!=home||!array(members,3,8)||members->count<1||members->count>=3) goto fail;
            for(int i=0;i<members->count;i++) {
                Byte *member=((Byte **)members->data)[i];
                if(!object(member,0xab2)||member[0x30c]||PTR(member,0x340)!=home||member[0xab1]>2||member[0xab1]==kind) goto fail;
            }
        }
        if(preview) { fprintf(out,"OK Preview: native resident/home/entrance checks passed; nothing changed.\n");goto finish; }
        Byte *person=FN(0x4c51db0,Byte *(*)(Byte *,int,int,Byte *))(region,family_id,kind,home);
        error="Native resident creation refused; no automatic retry";
        if(!object(person,0xab2)) goto fail;
        error="A person was created but family/home registration is unexpected; do not repeat blindly";
        if(!registered(residents,person)||PTR(person,0x340)!=home||INT(person,0x348)<0||person[0xab1]!=kind) goto fail;
        fprintf(out,"OK Created one native resident in family %d, with home and regional registration. No calendar or approval override.\n",INT(person,0x348));goto finish;
    }
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
    if(mode==12) {
        error="Choose deer or hare; native herd settings or navigation are unavailable";
        Byte *component=PTR(engine,0x2d0);
        if((kind!=4&&kind!=10)||rich>1||!props||!object(component,0x148)||!object(PTR(engine,0x5b8),0x28)) goto fail;
        int minimum=INT(props,rich?0x14:0xc),maximum=INT(props,rich?0x18:0x10),wanted=0;
        error="Native wildlife population must be between 1 and 256; nothing changed";
        if(!world_wildlife_population(minimum,maximum,&wanted)||nodes->count>=10000) goto fail;
        int tag_added=0;
        error="Region resource availability tags unavailable; nothing changed";
        if(!ensure_region_kind(region,kind,1,&tag_added)) goto fail;
        /* Build every ground/border/collision plan before allocating a squad or
         * actor. The anchor keeps the clicked X/Y; only native height is snapped. */
        Vec places[256];
        error="Choose clear ground with enough room for the herd inside your region; nothing changed";
        if(!readable(PTR(engine,0x2c0),0x450)||!object(PTR(engine,0x5b8),0x2b0)) goto fail;
        for(int i=0;i<wanted;i++) {
            double dx=0,dy=0;
            if(!world_wildlife_offset(i,wanted,&dx,&dy)) goto fail;
            places[i]=pos;places[i].x+=dx;places[i].y+=dy;
            struct { float height; Byte valid,padding[3]; } ground={0};
            FN(0x2d48ac0,void *(*)(Byte *,void *,Vec *,int))(PTR(engine,0x5b8),&ground,places+i,2);
            if(ground.valid!=1||!isfinite(ground.height)) goto fail;
            places[i].z=ground.height;
            if(!finite_vec(places[i])||FN(0x4cc9ab0,Byte *(*)(Byte *,Vec *,int))(engine,places+i,0)!=region||
                FN(0x4c8e610,Byte(*)(Byte *,Vec *))(engine,places+i)) goto fail;
        }
        pos=places[0];
        if(preview) {
            fprintf(out,"OK Preview: place %s %s herd (%d animals) and huntable node at the click %.0f %.0f. Ground/border/blocker checks passed for all animals. Nothing changed.\n",
                rich?"rich":"normal",resource_kind_name(kind),wanted,pos.x,pos.y);goto finish;
        }
        /* Same native squad/animal/node registration primitives as world
         * generation; explicit anchor replaces its random-site search. */
        struct __attribute__((aligned(16))) { Byte data[0x410]; } temporary={0};
        FN(0x4a6b590,void(*)(Byte *))(temporary.data);
        Array *label=(Array *)(temporary.data+0x28);
        if(label->data) FN(0x1128900,void(*)(void *))(label->data);
        memset(label,0,sizeof(*label));
        FN(0x10cd540,void(*)(Array *,const wchar_t *))(label,kind==4?L"Deer":L"Hare");
        temporary.data[0x10]=5;INT(temporary.data,0x48)=102;INT(temporary.data,0x60)=wanted;
        memcpy(temporary.data+0x98,&pos,sizeof(pos));memcpy(temporary.data+0xb8,&pos,sizeof(pos));
        PTR(temporary.data,0x1f8)=region;
        int id=0;
        FN(0x4d67b80,int *(*)(Byte *,int *,Byte *))(component,&id,temporary.data);
        FN(0x4a6bbd0,void(*)(Byte *))(temporary.data);
        Byte *squad=id>0?FN(0x4d63100,Byte *(*)(Byte *,int))(component,id):NULL;
        error="Native wildlife squad registration failed; do not repeat blindly";
        if(!readable(squad,0x410)||squad[0x10]!=5||INT(squad,0x64)!=id) goto fail;
        for(int i=0;i<wanted;i++) {
            /* The animal factory reads 28 bytes of cargo, including an internal
             * trailing field, unlike the 24-byte Good used by mineral deposits. */
            struct { int type,amount; Byte rest[24]; } cargo={0};
            cargo.type=kind==4?36:43;
            Vec rotation={0,i*137.50776405003785,0};
            Byte *unit=FN(0x4ca31a0,Byte *(*)(Byte *,int,Vec *,Vec *,Byte *,int,void *,int))
                (engine,kind==4?8:20,places+i,&rotation,NULL,id,&cargo,18);
            if(!object(unit,0xab0)) break;
            memcpy(unit+0x2c0,&rotation,sizeof(rotation));
            FN(0x4de6270,void(*)(Byte *,Byte *,int))(unit,region,0);
            FN(0x4e27970,void(*)(Byte *))(unit);
        }
        squad=FN(0x4d63100,Byte *(*)(Byte *,int))(component,id);
        error="Native animal registration incomplete; do not repeat placement";
        if(!readable(squad,0x410)||!array((Array *)(squad+0x18),1000,8)) goto fail;
        int population=((Array *)(squad+0x18))->count;
        if(population<1) {
            FN(0x4d80780,void(*)(Byte *,int))(component,id);
            error="No animals created; empty squad removal requested";goto fail;
        }
        Byte *created=FN(0x4ce6620,Byte *(*)(Byte *,int,Vec *,int,Array *,int))(engine,kind,&pos,rich,NULL,id);
        error="Animals created but native node registration failed; do not repeat placement";
        if(!object(created,0x318)||PTR(created,0x2b0)!=region||INT(created,0x2b8)!=id||!registered(nodes,created)) goto fail;
        error="Herd created but region availability update failed; do not repeat placement";
        if(!ensure_region_kind(region,kind,0,&tag_added)) goto fail;
        int view_ready=sync_resource_view(created,pawn),before=0,after=0;
        int hud_ready=sync_resource_hud(engine,pawn,0,&before,&after);
        fprintf(out,"OK Created native %s herd: %d animals, squad %d, huntable resource node at the click %.0f %.0f. %s %s Resume simulation; hunting camp work area must include this site. No undo.\n",
            resource_kind_name(kind),population,id,pos.x,pos.y,view_ready?"Map view refreshed.":"View refresh unavailable.",
            hud_ready?"HUD synchronized.":"Use mobs.refresh_resource_icons.");goto finish;
    }
    if(mode==1||mode==6) {
        error="Resource template or capacity unavailable";
        if(!props||!supported(kind)||!object(PTR(props,0x30),0x40)||count<1) goto fail;
        int tag_added=0;
        error="Region aquatic availability tags unavailable; nothing changed";
        if(mode==1&&(kind==5||kind==11)&&!ensure_region_kind(region,kind,1,&tag_added)) goto fail;
        int capacity=amount?amount:INT(props,rich?0x18:0x10);
        if(capacity<1||capacity>1000000||INT(props,4)<1||INT(props,4)>10000) goto fail;
        double scale=0;
        error="Native resource size range unavailable; placement refused";
        if(!world_resource_scale(*(double *)(props+0x38),*(double *)(props+0x40),&scale)) goto fail;
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
            if(kind==5||kind==11) places[i].z=FN(0x4cc6d50,float(*)(Byte *,Vec *))(engine,&places[i]);
            else places[i].z=FN(0x4cee3d0,float(*)(Byte *,Vec *,int,int,int))(engine,&places[i],0,0,-1);
            error="Terrain height invalid";if(!finite_vec(places[i])) goto fail;
        }
        if(preview) { fprintf(out,"OK Preview: create %d clump(s), %d units each, %s group, native size %.3g; nothing changed.\n",count,capacity,rich?"rich":"normal",scale);goto finish; }
        Array resource_name={0};uint64_t name=0;
        if(kind!=5&&kind!=11) {
            FN(0x4c76400,Array *(*)(Array *,int))(&resource_name,kind);
            error="Cannot resolve native resource name";
            if(!array(&resource_name,256,2)||resource_name.count<2) { if(resource_name.data) FN(0x1128900,void(*)(void *))(resource_name.data);goto fail; }
            FN(0x1251260,uint64_t *(*)(uint64_t *,const wchar_t *,int))(&name,resource_name.data,1);
            FN(0x1128900,void(*)(void *))(resource_name.data);
        }
        Byte *created[64]={0};Array clumps={created,0,64};
        for(int i=0;i<count;i++) {
            Transform t=transform(places[i]);Byte *template=PTR(props,0x30);
            t.scale[0]=t.scale[1]=t.scale[2]=scale;
            Byte *res=FN(0x4ce5780,Byte *(*)(Byte *,Byte *,Transform *,Byte **,int))(engine,region,&t,&template,0);
            if(!object(res,0x330)) break;
            /* Native aquatic generation preserves the spawned Blueprint's
             * resource identity/seasonal behavior. Node kind is a separate enum. */
            if(kind!=5&&kind!=11) { *(uint64_t *)(res+0x2f0)=name;INT(res,0x30c)=INT(props,4); }
            created[clumps.count++]=res;
            if((kind==5||kind==11)&&!world_fishing_identity_valid(kind,*(uint64_t *)(res+0x2f0),INT(res,0x30c),res[0x32c])) {
                for(int j=0;j<clumps.count;j++) FN(0x4cacc00,void(*)(Byte *,Byte *))(engine,created[j]);
                error="Native aquatic template has no valid fishing identity; created clumps removed";goto fail;
            }
            INT(res,0x308)=capacity;INT(res,0x310)=capacity;
        }
        Byte *node=clumps.count?spawn_node(engine,kind,pos,rich,&clumps):NULL;
        if(!object(node,0x318)) {
            for(int i=0;i<clumps.count;i++) FN(0x4cacc00,void(*)(Byte *,Byte *))(engine,created[i]);
            error="Game refused the resource group; created clumps removed";goto fail;
        }
        if(pond_resources) { PTR(created[0],0x2d8)=pond;append_pointer(pond_resources,created[0]); }
        error="Aquatic node created but region availability update failed; do not repeat placement";
        if(mode==1&&(kind==5||kind==11)&&!ensure_region_kind(region,kind,0,&tag_added)) goto fail;
        int view_ready=sync_resource_view(node,pawn);
        int before=0,after=0,hud_ready=sync_resource_hud(engine,pawn,0,&before,&after);
        fprintf(out,"OK Created %d/%d registered clump(s), %d units each, native size %.3g. %s %s No undo.\n",clumps.count,count,capacity,scale,
            view_ready?"Current map/mesh visibility refreshed.":"View refresh unavailable; do not repeat placement to repair it.",
            hud_ready?"HUD icons/hover list synchronized.":"HUD refresh unavailable; use mobs.refresh_resource_icons after loading.");goto finish;
    }
    if(mode==2||mode==3||mode==9||mode==10||mode==13) {
        error="Fishing repair requires an exact eel or fish node";
        if(mode==13&&kind!=5&&kind!=11) goto fail;
        Byte *nearest=NULL,*closest=NULL;double best=2500.0*2500,unfiltered_best=best;int nearby_kind=0;
        for(int i=0;i<nodes->count;i++) {
            Byte *node=((Byte **)nodes->data)[i];
            if(!object(node,0x318)||PTR(node,0x2b0)!=region||!supported(INT(node,0x2a8))) continue;
            int node_kind=INT(node,0x2a8);
            Array *clumps=(Array *)(node+0x2c0);if(!array(clumps,10000,8)) continue;
            if((mode==3 && count==0 && clumps->count==0 && INT(node,0x2b8)==0)||
                (mode==13 && clumps->count>0)) {
                Vec p;
                if(position(node,&p)) {
                    double d=distance(pos,p);
                    if((!kind||node_kind==kind)&&d<best) { nearest=node;closest=NULL;best=d; }
                }
            }
            for(int j=0;j<clumps->count;j++) {
                Byte *res=((Byte **)clumps->data)[j];Vec p;
                if(!object(res,0x330)||PTR(res,0x2b8)!=node||PTR(res,0x2d0)!=region||!position(res,&p)) continue;
                double d=distance(pos,p);
                if(d<unfiltered_best) { unfiltered_best=d;nearby_kind=node_kind; }
                if((!kind||node_kind==kind)&&d<best) { nearest=node;closest=res;best=d; }
            }
        }
        if(!nearest&&nearby_kind) {
            if(mode==13) {
                fprintf(out,"ERROR No nearby %s shoal matches. Nearby resource is %s. Fish and eel are separate; nothing changed.\n",resource_kind_name(kind),resource_kind_name(nearby_kind));goto finish;
            }
            const char *operation=mode==2?(rich?"rich":"normal"):mode==3?(count==1?"remove_clump":"remove"):mode==9?"add":"refresh";
            fprintf(out,"ERROR No nearby %s node matches. Nearby owned resource is %s; try mobs.resource %s %s%s. Nothing changed.\n",
                resource_kind_name(kind),resource_kind_name(nearby_kind),operation,resource_kind_name(nearby_kind),mode==9?" <amount>":"");goto finish;
        }
        error="No matching owned surface resource within 2500 game units";if(!nearest) goto fail;
        Array *clumps=(Array *)(nearest+0x2c0);
        if(mode==3 && count==0 && clumps->count==0) {
            if(preview) { fprintf(out,"OK Preview: remove one empty %s node; underground reserves are separate. Nothing changed.\n",resource_kind_name(INT(nearest,0x2a8)));goto finish; }
            remove_empty_node(engine,nearest);
            int before=0,after=0;sync_resource_hud(engine,pawn,0,&before,&after);
            fprintf(out,"OK Removed empty resource node. Underground reserves unchanged; use mobs.remove_deposit for those. No undo.\n");goto finish;
        }
        Byte *targets[10000];int n=(count==1&&mode==3)||mode==9?1:clumps->count;
        if(n==1&&((count==1&&mode==3)||mode==9)) targets[0]=closest;else memcpy(targets,clumps->data,(size_t)n*8);
        props=properties(settings,INT(nearest,0x2a8));error="Resource properties unavailable";if(!props) goto fail;
        for(int i=0;i<n;i++) {
            Byte *res=targets[i];error="Resource group contains an invalid or attached clump; no changes";
            if(!object(res,0x330)||PTR(res,0x2b8)!=nearest||PTR(res,0x2d0)!=region||PTR(res,0x2d8)) goto fail;
            if(mode==2 && (INT(res,0x310)<1||INT(res,0x310)>1000000||INT(res,0x308)<0||INT(res,0x308)>INT(res,0x310))) goto fail;
        }
        if(mode==13) {
            /* Defaults are read from the live game class, never guessed from
             * Fish/Eel node labels or inventory item IDs. Reject unresolved CDOs. */
            Byte *template=PTR(props,0x30);
            Byte *defaults=object(template,0x118)?PTR(template,0x110):NULL;
            error="Native fishing template defaults are unavailable; no changes";
            if(!object(defaults,0x330)||!world_fishing_identity_valid(kind,*(uint64_t *)(defaults+0x2f0),INT(defaults,0x30c),defaults[0x32c])) goto fail;
            int tag_added=0;
            error="Region aquatic availability tags unavailable; nothing changed";
            if(!ensure_region_kind(region,kind,1,&tag_added)) goto fail;
            Vec places[10000];int identity_changes=0,missing=0;
            for(int i=0;i<n;i++) {
                Byte *res=targets[i];
                error="Fishing clump differs from native template or has invalid quantities; no changes";
                if(PTR(res,0x10)!=template||INT(res,0x308)<0||INT(res,0x310)<1||INT(res,0x310)>1000000||INT(res,0x308)>INT(res,0x310)||
                    !position(res,places+i)||!object(PTR(res,0x1b8),0x230)||!object(PTR(res,0x2a8),0x278)) goto fail;
                places[i].z=FN(0x4cc6d50,float(*)(Byte *,Vec *))(engine,places+i);
                if(!finite_vec(places[i])) goto fail;
                if(*(uint64_t *)(res+0x2f0)!=*(uint64_t *)(defaults+0x2f0)||INT(res,0x30c)!=INT(defaults,0x30c)||res[0x32c]!=defaults[0x32c]) identity_changes++;
                if(!registered(resources,res)) missing++;
            }
            if(preview) {
                fprintf(out,"OK Preview: repair %d %s clump(s): %d template identity/seasonal changes, %d missing region registrations, %d missing availability tag; native height/view refresh. Amounts/capacity/richness unchanged.\n",n,resource_kind_name(kind),identity_changes,missing,tag_added);goto finish;
            }
            for(int i=0;i<n;i++) {
                Byte *res=targets[i];Transform t;memcpy(&t,PTR(res,0x1b8)+0x1d0,sizeof(t));
                t.pos[2]=places[i].z;
                if(!FN(0x34d6860,Byte(*)(Byte *,Transform *,int,void *,int))(res,&t,0,NULL,1)) {
                    fprintf(out,"OK Fishing repair stopped at clump %d/%d; %d completed. Amounts unchanged; do not respawn the node.\n",i+1,n,i);goto finish;
                }
                *(uint64_t *)(res+0x2f0)=*(uint64_t *)(defaults+0x2f0);
                INT(res,0x30c)=INT(defaults,0x30c);res[0x32c]=defaults[0x32c];
                if(!registered(resources,res)) append_pointer(resources,res);
            }
            error="Clumps repaired but region availability update failed";
            if(!ensure_region_kind(region,kind,0,&tag_added)) goto fail;
            refresh_rich(settings,props,nearest,nearest[0x2ac]!=0);
            int view_ready=sync_resource_view(nearest,pawn),before=0,after=0;
            int hud_ready=sync_resource_hud(engine,pawn,0,&before,&after);
            fprintf(out,"OK Repaired %d %s clump(s): native template identity/seasonal flag, height, region/spatial registration and availability tag. %s %s Amounts/capacity/richness unchanged. Resume simulation to check fishing; save/reload persistence needs testing. No undo.\n",
                n,resource_kind_name(kind),view_ready?"View refreshed.":"View refresh unavailable.",hud_ready?"HUD synchronized.":"Use mobs.refresh_resource_icons.");goto finish;
        }
        if(mode==10) {
            Vec places[10000];double scale=0;
            error="Refresh supports land resource groups only; fish/eel and attached resources are excluded";
            if(INT(nearest,0x2a8)==5||INT(nearest,0x2a8)==11) goto fail;
            error="Native resource size or scene component unavailable; nothing changed";
            if(!world_resource_scale(*(double *)(props+0x38),*(double *)(props+0x40),&scale)) goto fail;
            for(int i=0;i<n;i++) {
                if(!position(targets[i],places+i)||!object(PTR(targets[i],0x1b8),0x230)||
                    !object(PTR(targets[i],0x2a8),0x278)) goto fail;
                places[i].z=FN(0x4cee3d0,float(*)(Byte *,Vec *,int,int,int))(engine,places+i,0,0,-1);
                error="Terrain height invalid; nothing changed";if(!finite_vec(places[i])) goto fail;
            }
            if(preview) { fprintf(out,"OK Preview: refresh terrain height, native size %.3g and current-view visibility for %d clump(s). Amounts, capacity and richness unchanged.\n",scale,n);goto finish; }
            for(int i=0;i<n;i++) {
                Transform t;memcpy(&t,PTR(targets[i],0x1b8)+0x1d0,sizeof(t));
                t.pos[0]=places[i].x;t.pos[1]=places[i].y;t.pos[2]=places[i].z;
                t.scale[0]=t.scale[1]=t.scale[2]=scale;
                if(!FN(0x34d6860,Byte(*)(Byte *,Transform *,int,void *,int))(targets[i],&t,0,NULL,1)) {
                    fprintf(out,"OK Refresh stopped: game refused clump %d/%d after %d transform updates. Amounts unchanged.\n",i+1,n,i);goto finish;
                }
            }
            error="Transforms refreshed but view components unavailable; amounts unchanged";
            if(!sync_resource_view(nearest,pawn)) goto fail;
            int before=0,after=0,hud_ready=sync_resource_hud(engine,pawn,0,&before,&after);
            fprintf(out,"OK Refreshed %d clump(s) at native size %.3g, on terrain, with current-view visibility. %s Amounts, capacity and richness unchanged. No undo.\n",n,scale,
                hud_ready?"HUD icons/hover list synchronized.":"HUD refresh unavailable; use mobs.refresh_resource_icons.");goto finish;
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
        if(preview) { fprintf(out,"OK Preview: %s %d %s clump(s); nothing changed.\n",mode==2?(rich?"mark rich":"mark normal"):"remove",n,resource_kind_name(INT(nearest,0x2a8)));goto finish; }
        int edited_kind=INT(nearest,0x2a8);
        if(mode==2) {
            for(int i=0;i<n;i++) { Byte *res=targets[i];int after=0;world_rich_amount(INT(res,0x308),INT(res,0x310),capacity,&after);INT(res,0x308)=after;INT(res,0x310)=capacity; }
            refresh_rich(settings,props,nearest,rich);
        } else {
            for(int i=0;i<n;i++) FN(0x4cacc00,void(*)(Byte *,Byte *))(engine,targets[i]);
            if(count==0&&registered(nodes,nearest)) FN(0x4cad090,void(*)(Byte *,Byte *))(engine,nearest);
        }
        int before=0,after=0,hud_ready=sync_resource_hud(engine,pawn,0,&before,&after);
        fprintf(out,"OK %s %d %s clump(s). %s No undo.\n",mode==2?(rich?"Marked rich":"Marked normal"):"Removed",n,resource_kind_name(edited_kind),
            hud_ready?"HUD icons/hover list synchronized.":"HUD refresh unavailable; use mobs.refresh_resource_icons.");goto finish;
    }
    if(mode==4) {
        error="Choose iron, clay or salt and a positive amount";
        if((kind!=1&&kind!=2&&kind!=3)||amount<1) goto fail;
        double scale=0;
        error="Mineral resource template or native size unavailable";
        if(!props||!object(PTR(props,0x30),0x40)||!world_resource_scale(*(double *)(props+0x38),*(double *)(props+0x40),&scale)) goto fail;
        if(preview) { fprintf(out,"OK Preview: create %d surface units plus %d underground units and a map node; nothing changed.\n",amount,amount);goto finish; }
        Good good={0};good.type=kind==1?145:kind==2?14:146;good.amount=amount;
        Transform t=transform(pos);
        Byte *decal=FN(0x4ce2b30,Byte *(*)(Byte *,Good *,Transform *,int,int,int))(engine,&good,&t,1,-1,rich);
        error="Game refused underground deposit";if(!object(decal,0x2d8)||!registered(deposits,decal)) goto fail;
        /* A real clump supplies the surface amount and survives save/load. The
         * separate underground reserve is for deep mining, as in natural nodes. */
        pos.z=t.pos[2];t=transform(pos);t.scale[0]=t.scale[1]=t.scale[2]=scale;
        Byte *template=PTR(props,0x30);
        Byte *res=FN(0x4ce5780,Byte *(*)(Byte *,Byte *,Transform *,Byte **,int))(engine,region,&t,&template,0);
        Byte *node=NULL;
        if(object(res,0x330)) {
            Array resource_name={0};uint64_t name=0;
            FN(0x4c76400,Array *(*)(Array *,int))(&resource_name,kind);
            if(array(&resource_name,256,2)&&resource_name.count>1) {
                FN(0x1251260,uint64_t *(*)(uint64_t *,const wchar_t *,int))(&name,resource_name.data,1);
                *(uint64_t *)(res+0x2f0)=name;INT(res,0x308)=amount;INT(res,0x310)=amount;INT(res,0x30c)=INT(props,4);
                Array clumps={&res,1,1};node=spawn_node(engine,kind,pos,rich,&clumps);
            }
            if(resource_name.data) FN(0x1128900,void(*)(void *))(resource_name.data);
            if(!object(node,0x318)) FN(0x4cacc00,void(*)(Byte *,Byte *))(engine,res);
        }
        if(!object(node,0x318)) { /* Roll back the new decal if its map node failed. */
            Byte *tree=PTR(region,0x738);if(tree) FN(0x4ba40c0,void(*)(Byte *,Byte *))(tree,decal);
            erase_pointer(deposits,decal);destroy(decal);error="Map node creation failed; new underground deposit removed";goto fail;
        }
        sync_resource_view(node,pawn);
        int before=0,after=0,hud_ready=sync_resource_hud(engine,pawn,0,&before,&after);
        fprintf(out,"OK Created mineral group: %d surface units plus %d underground units, with ground-facing decal and map node. %s No undo.\n",amount,amount,
            hud_ready?"HUD icons/hover list synchronized.":"HUD refresh unavailable; use mobs.refresh_resource_icons.");goto finish;
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
        Vec reserve_at;error="Deposit position unavailable";if(!position(nearest,&reserve_at)) goto fail;
        Byte *legacy[64];int legacy_count=0;
        int reserve_kind=INT(nearest,0x2b0)==145?1:INT(nearest,0x2b0)==14?2:3;
        for(int i=0;i<nodes->count;i++) {
            Byte *node=((Byte **)nodes->data)[i];Vec p;
            if(!object(node,0x318)||PTR(node,0x2b0)!=region||INT(node,0x2a8)!=reserve_kind||!position(node,&p)||distance(p,reserve_at)>1) continue;
            Array *clumps=(Array *)(node+0x2c0);
            if(!array(clumps,10000,8)||clumps->count) continue;
            error="Too many overlapping empty markers; removal refused";if(legacy_count>=64) goto fail;
            legacy[legacy_count++]=node;
        }
        if(preview) { fprintf(out,"OK Preview: remove nearest underground deposit/decal (%d units) and %d colocated empty legacy marker(s); real surface clumps remain.\n",INT(nearest,0x2b4),legacy_count);goto finish; }
        for(int i=0;i<legacy_count;i++) remove_empty_node(engine,legacy[i]);
        Byte *tree=PTR(region,0x738);if(tree) FN(0x4ba40c0,void(*)(Byte *,Byte *))(tree,nearest);
        erase_pointer(deposits,nearest);destroy(nearest);
        int before=0,after=0;sync_resource_hud(engine,pawn,0,&before,&after);
        fprintf(out,"OK Removed underground deposit/decal and colocated empty legacy markers. Real surface groups remain; use mobs.resource remove if desired. No undo.\n");goto finish;
    }
fail:
    fprintf(out,"ERROR %s\n",error);
finish:
    if(in) fclose(in);
    fclose(out);return 0;
}
BOOL WINAPI DllMain(HINSTANCE instance,DWORD reason,LPVOID reserved) { (void)reserved;if(reason==DLL_PROCESS_ATTACH) module=instance;return TRUE; }
