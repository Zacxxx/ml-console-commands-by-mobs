#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
static int allocations=0,fail_after=-1;
static void *allocate(void *p,size_t size) {
    if(fail_after==0) return NULL;
    if(fail_after>0) fail_after--;
    if(!p) allocations++;
    void *result=realloc(p,size);
    if(!result && !p) allocations--;
    return result;
}
static void release(void *p) { if(p) { allocations--; free(p); } }
#define UX_REALLOC allocate
#define UX_FREE release
#include "../../src/mobs_console/Native/autocomplete_tree.h"
static const uint16_t bread[]={'M','O','B','S','.','G','I','V','E',' ','B','R','E','A','D',0};
static const uint16_t barley[]={'M','O','B','S','.','G','I','V','E',' ','B','A','R','L','E','Y',0};
static const uint16_t unicode[]={'M','O','B','S',' ',0x00C9,0};
int main(void) {
    _Static_assert(sizeof(UxNode)==40,"Unreal node layout");
    UxNode root={0}; int nodes=0;
    assert(ux_insert(&root,bread,0,&nodes));
    assert(ux_insert(&root,barley,1,&nodes));
    const UxNode *at=ux_child(&root,'M'); assert(at && at->indices.count==0);
    at=ux_child(at,'O'); at=ux_child(at,'B'); at=ux_child(at,'S'); at=ux_child(at,'.');
    at=ux_child(at,'G'); at=ux_child(at,'I'); at=ux_child(at,'V'); at=ux_child(at,'E');
    assert(at->indices.count==2); /* Arguments appear only at the complete command. */
    at=ux_child(at,' '); at=ux_child(at,'B');
    assert(at && at->indices.count==2 && ((int32_t *)at->indices.data)[1]==1);
    assert(!ux_child(at,'X'));
    assert(ux_insert(&root,unicode,2,&nodes));
    assert(ux_child(ux_child(ux_child(ux_child(ux_child(ux_child(&root,'M'),'O'),'B'),'S'),' '),0x00C9));
    ux_destroy(&root); assert(allocations==0);
    for(int fail=0;fail<60;fail++) {
        root=(UxNode){0}; nodes=0; fail_after=fail;
        ux_insert(&root,bread,0,&nodes);
        ux_destroy(&root); assert(allocations==0);
    }
    puts("Autocomplete trie prefix matching, UTF16 layout and allocation failure cleanup passed");
}
