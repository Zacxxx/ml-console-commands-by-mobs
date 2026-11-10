#include <assert.h>
#include <math.h>
#include "../../src/mobs_console/Native/world_plan.h"
int main(void) {
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
