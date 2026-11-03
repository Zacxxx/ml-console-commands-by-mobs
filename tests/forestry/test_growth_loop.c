#include "../../src/mobs_console/Native/forestry_growth.h"
#include <assert.h>
#include <stdio.h>
typedef struct { int stages[5],count,calls; } Fixture;
static int count(void *p) { return ((Fixture *)p)->count; }
static int advance(void *p,int index) {
    Fixture *f=p; f->calls++;
    if(f->stages[index]<0) return 0;
    if(++f->stages[index]<3) return 1;
    for(int i=index;i<f->count-1;i++) f->stages[i]=f->stages[i+1];
    f->count--; return 1;
}
int main(void) {
    Fixture f={{0,1,2,0,0},4,0};
    ForestryOps ops={&f,count,advance};
    ForestryResult result=forestry_finish(ops,100,0);
    assert(!result.error && f.count==0 && result.completed==4 && result.blocked==0 && f.calls==9);
    Fixture stalled={{-1,0,2,0,0},3,0}; ops.context=&stalled;
    result=forestry_finish(ops,100,0);
    assert(!result.error && stalled.count==1 && result.completed==2 && result.blocked==1 && result.steps==5);
    Fixture partial={{0,0,0,0,0},5,0}; ops.context=&partial;
    result=forestry_finish(ops,4,0);
    assert(!result.error && result.steps==4 && result.completed==1 && partial.count==4);
    result=forestry_finish(ops,100,result.next_index);
    assert(!result.error && partial.count==0 && result.completed==4);
    Fixture prefix={{-1,0,0,0,0},2,0}; ops.context=&prefix;
    result=forestry_finish(ops,1,0);
    assert(result.blocked==1 && result.next_index==1);
    result=forestry_finish(ops,100,result.next_index);
    assert(prefix.count==1 && result.completed==1 && result.next_index==1);
    puts("Forestry growth processes every stage, handles array compaction and reports blocked entries");
}
