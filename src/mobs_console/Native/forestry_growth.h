/* Original Mobs bounded growth driver; independent of Unreal memory layout. */
typedef struct {
    void *context;
    int (*count)(void *);
    /* 1: stage/scale progressed; 0: blocked; -1: invalid native state. */
    int (*advance)(void *,int);
} ForestryOps;
typedef struct { int completed,blocked,steps,error,next_index; } ForestryResult;
static ForestryResult forestry_finish(ForestryOps ops,int budget,int start_index) {
    ForestryResult result={0};
    int index=start_index,attempts=0;
    while(index<ops.count(ops.context) && result.steps<budget) {
        if(attempts>=8) { result.blocked++; index++; attempts=0; continue; }
        int before=ops.count(ops.context);
        int progress=ops.advance(ops.context,index);
        result.steps++;
        int after=ops.count(ops.context);
        if(progress<0 || after<0 || after>before) { result.error=1; break; }
        if(after<before) {
            result.completed+=before-after;
            attempts=0; /* Compaction moved the next tree into this index. */
        } else if(!progress) {
            result.blocked++; index++; attempts=0;
        } else attempts++;
    }
    result.next_index=index;
    return result;
}
