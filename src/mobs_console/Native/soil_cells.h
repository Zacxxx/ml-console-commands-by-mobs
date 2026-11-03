/* Original Mobs soil edit planning, independent of Unreal object access. */
#include <math.h>
typedef struct { int index,channel; float before,base_before,after,base_after; } SoilChange;
static int soil_in_circle(int index,double x,double y,double radius) {
    double dx=(index%1024)*217.96875-111600.0-x;
    double dy=(index/1024)*217.96875-111600.0-y;
    return dx*dx+dy*dy<=radius*radius;
}
/* -1 invalid, 0 unchanged, 1 has a planned change. Restore keeps baseline intact. */
static int soil_plan(int index,int channel,float current,float baseline,int restore,float value,SoilChange *out) {
    if(index<0 || index>=1024*1024 || channel<0 || channel>2 || !isfinite(current) || !isfinite(baseline) ||
        current<0 || current>1.001f || baseline<0 || baseline>1.001f || !isfinite(value) || value<0 || value>1) return -1;
    float after=restore?baseline:value;
    float base_after=restore?baseline:value;
    if(current==after && baseline==base_after) return 0;
    *out=(SoilChange){index,channel,current,baseline,after,base_after};
    return 1;
}
