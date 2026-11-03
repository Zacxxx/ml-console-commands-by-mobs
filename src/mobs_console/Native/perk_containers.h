/* Original Mobs helpers for the exact 0.8.117 trivial UE sparse containers.
 * Caller validates every pointer, index, bit array and hash chain first.
 * Never used with containers whose elements own memory or require destructors. */
#include <stdint.h>
#include <string.h>
static int32_t get_i32(const void *p, int offset) {
    int32_t value; memcpy(&value,(const unsigned char *)p+offset,4); return value;
}
static void put_i32(void *p, int offset, int32_t value) {
    memcpy((unsigned char *)p+offset,&value,4);
}
static uint32_t *set_bits(unsigned char *set) {
    uint32_t *heap; memcpy(&heap,set+32,8);
    return heap ? heap : (uint32_t *)(set+16);
}
static int32_t *set_hash(unsigned char *set) {
    int32_t *heap; memcpy(&heap,set+64,8);
    return heap ? heap : (int32_t *)(set+56);
}
static int set_occupied(unsigned char *set, int index) {
    return index>=0 && index<get_i32(set,8) &&
        (set_bits(set)[index/32] & (1u<<(index%32)))!=0;
}
static int set_contains(unsigned char *set, int stride, unsigned char key) {
    unsigned char *data=*(unsigned char **)set;
    for (int i=0;i<get_i32(set,8);i++)
        if (set_occupied(set,i) && data[i*stride]==key) return 1;
    return 0;
}
static int set_remove(unsigned char *set, int stride, int index) {
    if (!set_occupied(set,index)) return 0;
    unsigned char *data=*(unsigned char **)set, *node=data+index*stride;
    int hash_index=get_i32(node,stride-4);
    int32_t *link=set_hash(set)+hash_index;
    while (*link!=index) link=(int32_t *)(data+*link*stride+stride-8);
    *link=get_i32(node,stride-8);
    int first=get_i32(set,48);
    if (first!=-1) put_i32(data+first*stride,0,index);
    put_i32(node,0,-1); put_i32(node,4,first);
    put_i32(set,48,index); put_i32(set,52,get_i32(set,52)+1);
    set_bits(set)[index/32] &= ~(1u<<(index%32));
    return 1;
}
