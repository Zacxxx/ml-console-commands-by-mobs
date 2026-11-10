/* Copyright 2026 Mobs. MIT licensed. Bounded resource amount plans. */
#ifndef MOBS_WORLD_PLAN_H
#define MOBS_WORLD_PLAN_H
#include <stdint.h>
#include <math.h>
#include <stddef.h>
#include <string.h>
#define WORLD_MAX_RESOURCE 1000000
/* Copy the authoritative registry into the HUD snapshot after caller-side
 * capacity validation/growth. The caller commits its count after this copy. */
static int world_copy_nodes(void **destination,int capacity,void *const *source,int count) {
    if(count<0||count>100000||capacity<count||(count&&(!destination||!source))) return 0;
    if(count) memmove(destination,source,(size_t)count*sizeof(void *));
    return 1;
}
/* ResourceSettings.ScaleVariation is a double pair, not the actor default scale.
 * Use its midpoint so placement/repair does not consume the game's random stream. */
static int world_resource_scale(double minimum,double maximum,double *scale) {
    if(!isfinite(minimum)||!isfinite(maximum)||minimum<=0||maximum<minimum||maximum>10000) return 0;
    *scale=minimum+(maximum-minimum)*0.5;return 1;
}
static int world_rich_amount(int before,int capacity,int next_capacity,int *after) {
    if(before<0||capacity<1||capacity>WORLD_MAX_RESOURCE||before>capacity||
        next_capacity<1||next_capacity>WORLD_MAX_RESOURCE) return 0;
    *after=(int)(((int64_t)before*next_capacity)/capacity);return 1;
}
static int world_add_amount(int before,int capacity,int amount,int *after,int *next_capacity) {
    if(before<0||capacity<1||capacity>WORLD_MAX_RESOURCE||before>capacity||amount<1||
        amount>WORLD_MAX_RESOURCE||before>WORLD_MAX_RESOURCE-amount) return 0;
    *after=before+amount;*next_capacity=*after>capacity?*after:capacity;return 1;
}
#endif
