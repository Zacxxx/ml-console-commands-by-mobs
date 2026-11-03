#include "../../src/mobs_console/Native/perk_containers.h"
#include <assert.h>
#include <stdio.h>
int main(void) {
    unsigned char map[80] = {0}, nodes[60] = {0};
    *(void **)map = nodes;
    put_i32(map,8,3); put_i32(map,12,3);
    put_i32(map,40,3); put_i32(map,44,128);
    put_i32(map,48,-1); put_i32(map,72,1);
    put_i32(map,16,7); put_i32(map,56,2);
    for(int i=0;i<3;i++) {
        nodes[i*20]=(unsigned char)(i+1);
        put_i32(nodes+i*20,12,i-1); put_i32(nodes+i*20,16,0);
    }
    assert(set_contains(map,20,1) && set_contains(map,20,3));
    assert(set_remove(map,20,1));
    assert(!set_contains(map,20,2) && set_contains(map,20,3));
    assert(get_i32(nodes+40,12)==0 && get_i32(map,52)==1);
    assert(get_i32(map,48)==1 && get_i32(nodes+20,4)==-1);
    assert(set_remove(map,20,2));
    assert(get_i32(map,56)==0 && get_i32(nodes+20,0)==2);
    assert(set_remove(map,20,0));
    assert(get_i32(map,56)==-1 && get_i32(map,52)==3);
    assert(!set_remove(map,20,0));
    puts("Perk sparse container deletion, collision chains and free list passed");
}
