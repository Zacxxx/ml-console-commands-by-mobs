#include <assert.h>
#include <math.h>
#include "../../src/mobs_console/Native/world_plan.h"
static int pond_samples=0,pond_corner_block=0,pond_edge_block=0;
static double pond_gradient=0;
static int pond_probe(double x,double y,double *height,void *context) {
    (void)context;
    pond_samples++;
    if(pond_corner_block && x>70 && y>70) return 0;
    if(pond_edge_block && fabs(x-250)<1 && fabs(y-1000)<1) return 0;
    *height=pond_gradient*x;
    return 1;
}
int main(void) {
    /* Regression: minerals have NULL generic templates on 0.8.117. */
    assert(world_mineral_template(2,11,12,13,0)==11);
    assert(world_mineral_template(3,11,12,13,0)==12);
    assert(world_mineral_template(1,11,12,13,0)==13);
    assert(world_mineral_template(2,11,12,13,99)==11);
    assert(world_mineral_template(2,0,12,13,99)==99);
    assert(world_mineral_template(6,11,12,13,99)==99);

    /* Diamond: its empty rectangular corners must not block relaxed placement. */
    double pond_shape[]={0,-100,100,0,0,100,-100,0};
    double centre=0,span=0;
    assert(world_pond_contains(pond_shape,4,0,0));
    assert(world_pond_contains(pond_shape,4,50,50));
    assert(!world_pond_contains(pond_shape,4,80,80));
    pond_corner_block=1;
    assert(world_pond_plan(pond_shape,4,0,pond_probe,NULL,&centre,&span)==1);
    assert(world_pond_plan(pond_shape,4,1,pond_probe,NULL,&centre,&span)==-1);
    pond_corner_block=0; pond_gradient=3;
    assert(world_pond_plan(pond_shape,4,0,pond_probe,NULL,&centre,&span)==1 && span==600);
    assert(world_pond_plan(pond_shape,4,1,pond_probe,NULL,&centre,&span)==-2);
    pond_gradient=6;
    assert(world_pond_plan(pond_shape,4,0,pond_probe,NULL,&centre,&span)==-2);
    pond_gradient=0; pond_edge_block=1;
    double long_edge[]={-1000,-1000,1000,-1000,1000,1000,-1000,1000};
    /* Blocker between 5m interior grid points is still caught on the outline. */
    assert(world_pond_plan(long_edge,4,0,pond_probe,NULL,&centre,&span)==-1);
    pond_edge_block=0;
    assert(world_pond_plan(long_edge,4,0,pond_probe,NULL,&centre,&span)==1);
    pond_samples=0;
    double bad_shape[]={NAN,0,100,0,0,100};
    assert(world_pond_plan(bad_shape,3,0,pond_probe,NULL,&centre,&span)==0 && pond_samples==0);
    double degenerate[]={0,0,100,0,200,0};
    assert(world_pond_plan(degenerate,3,0,pond_probe,NULL,&centre,&span)==0);
    assert(world_pond_plan(pond_shape,4,2,pond_probe,NULL,&centre,&span)==0);

    int nx=0,ny=0;
    assert(world_pond_grid(1000,750,&nx,&ny));
    assert(nx%2==0 && ny%2==0 && 2000.0/nx<=500 && 1500.0/ny<=500);
    assert(world_pond_grid(1,1,&nx,&ny) && nx==2 && ny==2);
    assert(world_pond_grid(16000,16000,&nx,&ny) && nx==64 && ny==64);
    assert(!world_pond_grid(0,100,&nx,&ny));
    assert(!world_pond_grid(-1,100,&nx,&ny));
    assert(!world_pond_grid(INFINITY,100,&nx,&ny));
    assert(!world_pond_grid(100,NAN,&nx,&ny));
    assert(!world_pond_grid(16001,100,&nx,&ny));
    assert(!world_pond_grid(100,100,NULL,&ny));
    int population=0;
    assert(world_wildlife_population(10,20,&population) && population==15);
    assert(world_wildlife_population(1,1,&population) && population==1);
    assert(world_wildlife_population(1,256,&population) && population==128);
    assert(!world_wildlife_population(0,10,&population));
    assert(!world_wildlife_population(20,10,&population));
    assert(!world_wildlife_population(1,257,&population));
    assert(!world_wildlife_population(1,2,NULL));
    double offset_x=1,offset_y=1;
    assert(world_wildlife_offset(0,256,&offset_x,&offset_y));
    assert(offset_x==0 && offset_y==0);
    for(int i=0;i<256;i++) {
        assert(world_wildlife_offset(i,256,&offset_x,&offset_y));
        assert(isfinite(offset_x) && isfinite(offset_y));
        assert(offset_x*offset_x+offset_y*offset_y<=1000.0*1000.0);
        if(i) assert(offset_x!=0 || offset_y!=0);
    }
    assert(!world_wildlife_offset(-1,4,&offset_x,&offset_y));
    assert(!world_wildlife_offset(4,4,&offset_x,&offset_y));
    assert(!world_wildlife_offset(0,0,&offset_x,&offset_y));
    assert(!world_wildlife_offset(0,257,&offset_x,&offset_y));
    assert(world_fishing_identity_valid(11,123,32,1));
    assert(world_fishing_identity_valid(5,456,316,0));
    assert(!world_fishing_identity_valid(4,123,36,0));
    assert(!world_fishing_identity_valid(10,123,43,0));
    assert(!world_fishing_identity_valid(11,0,32,1));
    assert(!world_fishing_identity_valid(11,UINT64_C(1)<<32,32,1));
    assert(!world_fishing_identity_valid(11,123,0,1));
    assert(!world_fishing_identity_valid(11,123,10001,1));
    assert(!world_fishing_identity_valid(11,123,32,2));
    void *world_nodes[]={(void *)1,(void *)2,(void *)3};
    void *hud_nodes[]={(void *)1,(void *)9,(void *)9,(void *)9};
    assert(!world_copy_nodes(hud_nodes,2,world_nodes,3));
    assert(hud_nodes[1]==(void *)9);
    assert(world_copy_nodes(hud_nodes,4,world_nodes,3));
    assert(hud_nodes[0]==(void *)1 && hud_nodes[1]==(void *)2 && hud_nodes[2]==(void *)3);
    assert(world_nodes[1]==(void *)2);
    assert(world_copy_nodes(hud_nodes,4,world_nodes,1));
    assert(world_copy_nodes(NULL,0,NULL,0));
    assert(!world_copy_nodes(NULL,4,world_nodes,3));
    assert(!world_copy_nodes(hud_nodes,4,NULL,3));
    assert(!world_copy_nodes(hud_nodes,4,world_nodes,-1));
    double scale=0;
    assert(world_resource_scale(80,120,&scale) && scale==100);
    assert(world_resource_scale(0.8,1.2,&scale) && scale==1);
    assert(world_resource_scale(2.5,2.5,&scale) && scale==2.5);
    assert(!world_resource_scale(0,10,&scale));
    assert(!world_resource_scale(10,1,&scale));
    assert(!world_resource_scale(NAN,10,&scale));
    assert(!world_resource_scale(1,INFINITY,&scale));
    assert(!world_resource_scale(1,10001,&scale));
    int after=-1,capacity=-1;
    assert(world_rich_amount(50,100,1000,&after) && after==500);
    assert(world_rich_amount(0,100,1000,&after) && after==0);
    assert(world_rich_amount(100,100,1000,&after) && after==1000);
    assert(world_rich_amount(1000000,1000000,1000000,&after) && after==1000000);
    assert(!world_rich_amount(101,100,1000,&after));
    assert(!world_rich_amount(0,0,1000,&after));
    assert(!world_rich_amount(-1,100,1000,&after));
    assert(world_add_amount(50,100,75,&after,&capacity) && after==125 && capacity==125);
    assert(world_add_amount(50,100,25,&after,&capacity) && after==75 && capacity==100);
    assert(!world_add_amount(999999,1000000,2,&after,&capacity));
    assert(!world_add_amount(50,100,0,&after,&capacity));
    assert(!world_add_amount(50,100,-1,&after,&capacity));
    for(int before=0;before<=1000;before++) {
        assert(world_rich_amount(before,1000,250,&after));
        assert(after>=0 && after<=250);
        assert(after*1000<=before*250);
    }
    return 0;
}
