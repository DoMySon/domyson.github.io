---
title: allocator
date: 2022-04-21
categories: ['skynet']
description: 
toc: true
draft: false
---



# 简介

手动管理内存永远是最有效率的办法。


# 基于 `SLAB` 算法的分段内存分配器

`SLAB` 最开始是阅读 `linux` 源码学习的算法，在`skynet`中它确实有更优秀的性能，因为它直接分配了一块大共用内存，所以不会产生任何GC和真实分配,但在业务开发过程中，一旦忘记释放 那么这段内存将不能再被使用和获取了（也就是野指针），直到程序结束。最后的保守策略依然会向`runtime`申请内存，将会导致内存占用过高。

而且内置的`Debug`模式也无法定位到这个指针，原因在于 golang 堆栈伸缩会导致指针地址变动，所以 `Debug` 只能定位到存在 `memory-leak`，而无法知道具体位置。若需要具体位置则需要hook这个调用栈，性能方面得不偿失


> `slab-allocator` 对业务开发很不友好，最终只是将它保留作为可选项，是否使用取决于业务实际需要，因为它违背了 `skynet` 的设计初衷。



# 基于 `sync.Pool` 的分段内存分配器

将不同size的buffer放入不同的池中，按需进行分配，减少race的开销，这个方法虽然简单，但是性能是低于 `slab-allocator`。

但它确实能减轻心智负担，代价就是牺牲了部分性能以及gc压力，但这也是`skynet`默认使用的策略。如果需要使用可以在编译指令中指明`slab`




# API

+ `skynet.alloc(n)` 用以分配指定大小的内存块

+ `skynet.realloc(buf,n)` realloc函数会先检查buf，确保是否需要重新分配内存

+ `skynet.append(buf,data)` 简化了 `realloc` 和 `copy` 的操作。

+ `skynet.free(buf)` 释放一段内存,对于`slab` 而言，它会检查buf的地址是否属于当前段

{{< adsense-footer>}}
