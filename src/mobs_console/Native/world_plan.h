/* Copyright 2026 Mobs. MIT licensed. Bounded resource amount plans. */
#ifndef MOBS_WORLD_PLAN_H
#define MOBS_WORLD_PLAN_H
#include <stdint.h>
#define WORLD_MAX_RESOURCE 1000000
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
