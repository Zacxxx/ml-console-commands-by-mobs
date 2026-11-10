/* Copyright 2026 Mobs. MIT licensed. Unreal-compatible UTF16 prefix trie.
 * Allocation functions belong to the engine; the same layout is destroyed by UConsole.
 */
#ifndef MOBS_AUTOCOMPLETE_TREE_H
#define MOBS_AUTOCOMPLETE_TREE_H
#include <stdint.h>
#include <stddef.h>
#include <string.h>
typedef struct { void *data; int32_t count,capacity; } UxArray;
typedef struct UxNode { uint32_t key,padding; UxArray indices,children; } UxNode;
static int ux_push(UxArray *a,const void *item,size_t stride) {
    if(a->count==a->capacity) {
        int capacity=a->capacity ? a->capacity*2 : 4;
        void *data=UX_REALLOC(a->data,(size_t)capacity*stride);
        if(!data) return 0;
        a->data=data; a->capacity=capacity;
    }
    memcpy((unsigned char *)a->data+(size_t)a->count*stride,item,stride);
    a->count++; return 1;
}
static UxNode *ux_child(const UxNode *node,uint32_t key) {
    for(int i=0;i<node->children.count;i++) {
        UxNode *child=((UxNode **)node->children.data)[i];
        if(child->key==key) return child;
    }
    return NULL;
}
static int ux_insert(UxNode *root,const uint16_t *command,int32_t index,int *nodes) {
    UxNode *at=root;
    /* Keep argument variants out of broad command-prefix results. They remain
     * reachable through child nodes, and become visible at the full command. */
    int visible_from=0;
    for(int i=0;command[i];i++) if(command[i]==' ') { visible_from=i-1; break; }
    static const uint16_t advice[]={'M','O','B','S','.','A','D','V','I','C','E','.',0};
    int is_advice=1;
    for(int i=0;advice[i];i++) if(command[i]!=advice[i]) { is_advice=0; break; }
    if(is_advice && visible_from<11) visible_from=11;
    for(int i=0;command[i];i++) {
        if(i>=255) return 0;
        UxNode *child=ux_child(at,command[i]);
        if(!child) {
            if(*nodes>=65536) return 0;
            child=UX_REALLOC(NULL,sizeof(*child));
            if(!child) return 0;
            memset(child,0,sizeof(*child)); child->key=command[i];
            if(!ux_push(&at->children,&child,sizeof(child))) { UX_FREE(child); return 0; }
            (*nodes)++;
        }
        if(i>=visible_from && !ux_push(&child->indices,&index,sizeof(index))) return 0;
        at=child;
    }
    return 1;
}
static void ux_destroy(UxNode *node) {
    for(int i=0;i<node->children.count;i++) {
        UxNode *child=((UxNode **)node->children.data)[i];
        ux_destroy(child); UX_FREE(child);
    }
    UX_FREE(node->children.data); UX_FREE(node->indices.data);
    memset(node,0,sizeof(*node));
}
#endif
