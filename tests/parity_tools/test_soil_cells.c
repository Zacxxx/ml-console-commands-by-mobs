#include <assert.h>
#include "../../src/mobs_console/Native/soil_cells.h"
int main(void) {
    SoilChange change;
    assert(soil_plan(7,0,0.2f,0.8f,1,0,&change)==1);
    assert(change.before==0.2f && change.after==0.8f && change.base_after==0.8f);
    assert(soil_plan(7,0,0.8f,0.8f,1,0,&change)==0);
    assert(soil_plan(7,2,0.2f,0.8f,0,1,&change)==1);
    assert(change.after==1 && change.base_after==1 && change.base_before==0.8f);
    assert(soil_plan(-1,0,0.2f,0.8f,0,1,&change)==-1);
    assert(soil_plan(1024*1024,0,0.2f,0.8f,0,1,&change)==-1);
    assert(soil_plan(7,3,0.2f,0.8f,0,1,&change)==-1);
    assert(soil_plan(7,0,NAN,0.8f,0,1,&change)==-1);
    assert(soil_plan(7,0,0.2f,0.8f,0,1.1f,&change)==-1);
    assert(soil_in_circle(512+512*1024,0,0,1));
    assert(!soil_in_circle(513+512*1024,0,0,217));
    assert(soil_in_circle(513+512*1024,0,0,218));
    assert(soil_in_circle(0,-111600,-111600,1));
    return 0;
}
