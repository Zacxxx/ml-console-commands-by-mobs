#include <assert.h>
#include "../../src/mobs_console/Native/world_plan.h"
int main(void) {
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
