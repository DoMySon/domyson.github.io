# Go GC分析



# 如何启用GC跟踪

> GODEBUG=gctrace=1 go run *.go

其中 `gctrace=1` 表示只针对这个进程进行GC追踪


# 标记流程

> go采用三色标记法，主要是为了提高并发度，这样扫描过程可以拆分为多个阶段，而不用一次扫描全部

+ 黑 根节点扫描完毕，子节点也扫描完毕

+ 灰 根节点扫描完毕，子节点未扫描

+ 白 未扫描

扫描是从 .bss .data goroutine栈开始扫描，最终遍历整个堆上的对象树

## 标记 mark

标记过程是一个广度优先的遍历过程，扫描节点，将节点的子节点推送到任务队列中，然后递归扫描子叶节点，直到所有工作队列被排空

mark阶段会将白色对象标记，并推入队列中变为灰色


# write barrier

在应用进入 GC 标记阶段前的 stw 阶段，会将全局变量 runtime.writeBarrier.enabled 修改为 true，这时所有的堆上指针修改操作在修改之前便会额外调用 runtime.gcWriteBarrier


todo https://blog.csdn.net/asd1126163471/article/details/124113816
