/* Copyright 2026 Mobs. MIT licensed. Bounded resource amount plans. */
#ifndef MOBS_WORLD_PLAN_H
#define MOBS_WORLD_PLAN_H
#include <stdint.h>
#include <math.h>
#include <stddef.h>
#include <string.h>
#define WORLD_MAX_RESOURCE 1000000
/* Mineral templates live on RTSMultiEngineCPP, unlike generic resource kinds.
 * Prefer those authoritative classes even when a generic field is populated. */
static uintptr_t world_mineral_template(int kind,uintptr_t iron,uintptr_t clay,uintptr_t salt,uintptr_t generic) {
    uintptr_t native=kind==2?iron:kind==3?clay:kind==1?salt:0;
    return native?native:generic;
}
/* Conservatively sample the native rectangular pond bounds as half-extents.
 * Include centre, corners and interior points, at most 500 units apart. */
static int world_pond_grid(double x,double y,int *nx,int *ny) {
    if(!nx||!ny||!isfinite(x)||!isfinite(y)||x<=0||y<=0||x>16000||y>16000) return 0;
    *nx=(int)ceil(x/250.0);*ny=(int)ceil(y/250.0);
    /* Even interval counts include the exact clicked centre. */
    if(*nx&1) (*nx)++;
    if(*ny&1) (*ny)++;
    return *nx>=2&&*ny>=2&&*nx<=64&&*ny<=64;
}
/* Point-in-polygon includes its boundary. Coordinates are local pond XY units. */
static int world_pond_contains(const double *xy,int count,double x,double y) {
    if(!xy||count<3||count>256||!isfinite(x)||!isfinite(y)) return 0;
    int inside=0;
    for(int i=0,j=count-1;i<count;j=i++) {
        double ax=xy[2*j],ay=xy[2*j+1],bx=xy[2*i],by=xy[2*i+1];
        double dx=bx-ax,dy=by-ay,cross=dx*(y-ay)-dy*(x-ax);
        if(fabs(cross)<=1e-6*(fabs(dx)+fabs(dy)+1) &&
            x>=fmin(ax,bx)-1e-6&&x<=fmax(ax,bx)+1e-6&&
            y>=fmin(ay,by)-1e-6&&y<=fmax(ay,by)+1e-6) return 1;
        if((ay>y)!=(by>y) && x<ax+(y-ay)*dx/dy) inside=!inside;
    }
    return inside;
}
typedef int (*WorldPondProbe)(double x,double y,double *height,void *context);
static int world_pond_visit(double x,double y,WorldPondProbe probe,void *context,double *low,double *high) {
    double height=0;
    if(!probe(x,y,&height,context)||!isfinite(height)) return 0;
    if(height<*low) *low=height;
    if(height>*high) *high=height;
    return 1;
}
/* Relaxed: sample the real polygon, no extra margin, up to 10m height spread.
 * Strict retains the old rectangular footprint +1m and 2m height spread.
 * Every edge is checked at <=2.5m intervals; interior samples are <=5m apart.
 * Returns 1=valid, 0=bad shape/policy, -1=probe refusal, -2=height spread. */
static int world_pond_plan(const double *xy,int count,int strict,WorldPondProbe probe,void *context,
    double *centre_height,double *spread) {
    if(!xy||count<3||count>256||strict<0||strict>1||!probe||!centre_height||!spread) return 0;
    double ex=0,ey=0,area=0;
    for(int i=0,j=count-1;i<count;j=i++) {
        double x=xy[2*i],y=xy[2*i+1];
        if(!isfinite(x)||!isfinite(y)||fabs(x)>15900||fabs(y)>15900) return 0;
        ex=fmax(ex,fabs(x));ey=fmax(ey,fabs(y));
        area+=xy[2*j]*y-x*xy[2*j+1];
    }
    if(!isfinite(area)||fabs(area)<1||!world_pond_contains(xy,count,0,0)) return 0;
    if(strict) { ex+=100;ey+=100; }
    int nx=0,ny=0;
    if(!world_pond_grid(ex,ey,&nx,&ny)) return 0;
    if(!probe(0,0,centre_height,context)||!isfinite(*centre_height)) return -1;
    double low=*centre_height,high=*centre_height;
    for(int ix=0;ix<=nx;ix++) for(int iy=0;iy<=ny;iy++) {
        double x=ex*(2.0*ix/nx-1.0),y=ey*(2.0*iy/ny-1.0);
        if(!strict&&!world_pond_contains(xy,count,x,y)) continue;
        if(!world_pond_visit(x,y,probe,context,&low,&high)) return -1;
    }
    if(!strict) for(int i=0,j=count-1;i<count;j=i++) {
        double x=xy[2*j],y=xy[2*j+1],dx=xy[2*i]-x,dy=xy[2*i+1]-y;
        int steps=(int)ceil(hypot(dx,dy)/250.0);
        if(steps<1) steps=1;
        for(int k=0;k<=steps;k++)
            if(!world_pond_visit(x+dx*k/steps,y+dy*k/steps,probe,context,&low,&high)) return -1;
    }
    *spread=high-low;
    return *spread<=(strict?200.0:1000.0)?1:-2;
}
/* Preview and apply choose the same bounded population without using RNG. */
static int world_wildlife_population(int minimum,int maximum,int *population) {
    if(!population||minimum<1||maximum<minimum||maximum>256) return 0;
    *population=minimum+(maximum-minimum)/2;return 1;
}
/* Keep the node at the click; distribute its animals within 1000 game units.
 * Index zero stays at the anchor. Native ground/border checks follow this plan. */
static int world_wildlife_offset(int index,int count,double *x,double *y) {
    if(!x||!y||count<1||count>256||index<0||index>=count) return 0;
    double radius=60.0*sqrt((double)index),angle=index*2.399963229728653;
    *x=cos(angle)*radius;*y=sin(angle)*radius;return 1;
}
/* ENodeType is not a resource's FName or EItemType. Aquatic factories retain
 * Blueprint identity instead of deriving either field from the node enum. */
static int world_fishing_identity_valid(int kind,uint64_t name,int item,int seasonal) {
    return (kind==5||kind==11) && (uint32_t)name!=0 && item>0 && item<=10000 &&
        seasonal>=0 && seasonal<=1;
}
/* Copy the authoritative registry into the HUD snapshot after caller-side
 * capacity validation/growth. The caller commits its count after this copy. */
static int world_copy_nodes(void **destination,int capacity,void *const *source,int count) {
    if(count<0||count>100000||capacity<count||(count&&(!destination||!source))) return 0;
    if(count) memmove(destination,source,(size_t)count*sizeof(void *));
    return 1;
}
/* ResourceSettings.ScaleVariation is a double pair, not the actor default scale.
 * Use its midpoint so placement/repair does not consume the game's random stream. */
static int world_resource_scale(double minimum,double maximum,double *scale) {
    if(!isfinite(minimum)||!isfinite(maximum)||minimum<=0||maximum<minimum||maximum>10000) return 0;
    *scale=minimum+(maximum-minimum)*0.5;return 1;
}
static int world_rich_amount(int before,int capacity,int next_capacity,int *after) {
    if(before<0||capacity<1||capacity>WORLD_MAX_RESOURCE||before>capacity||
        next_capacity<1||next_capacity>WORLD_MAX_RESOURCE) return 0;
    *after=(int)(((int64_t)before*next_capacity)/capacity);return 1;
}
static int world_add_amount(int before,int capacity,int amount,int *after,int *next_capacity) {
    if(before<0||capacity<1||capacity>WORLD_MAX_RESOURCE||before>capacity||amount<1||
        amount>WORLD_MAX_RESOURCE||before>WORLD_MAX_RESOURCE-amount) return 0;
    *after=before+amount;*next_capacity=*after>capacity?*after:capacity;return 1;
}
#endif
