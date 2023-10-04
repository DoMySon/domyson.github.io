---
title: allocator
date: 2022-04-21
categories: ['sknt']
description: 
toc: true
draft: false
---



# 简介

`alloctor` 模块主要是为了减少`GC`而开发。现支持两套分配规则



# 基于 `SLAB` 算法的分段内存分配器

`SLAB` 最开始是阅读 `linux` 源码学习的算法，在`sknt`中它确实有更优秀的性能，因为它直接分配了一块共用内存，所以不会产生任何GC和真实分配,
，但在业务开发过程中，一旦忘记释放 那么这段内存将不能再被使用和获取了（也就是野指针），直到程序结束。

哪怕内置的`Debug`模式也无法定位到这个指针，原因在于 golang 堆栈伸缩会导致指针地址变动，所以 `Debug` 只能定位到存在 `memory-leak`，而无法知道具体位置。若需要具体位置则需要hook这个调用栈，性能方面得不偿失

`slab-allocator` 对业务开发很不友好，最终只是将它保留作为可选项，是否使用取决于业务实际需要，因为它违背了 `sknt` 的设计初衷。

如果需要使用可以在编译指令中指明`slab`


> 2020-10-18 阅读sync.Pool源码，看看能不能够和指定的P进行绑定，减少锁


# 基于 `sync.Pool` 的分段内存分配器

将不同size的buffer放入不同的池中，按需进行分配，减少race的开销

这个方法虽然简单，但是性能是低于 `slab-allocator`。

但它确实能减轻心智负担，代价就是牺牲了部分性能以及gc压力，但这也是`sknt`默认使用的策略。



# API

+ `sknt.alloc(n)` 用以分配指定大小的内存块

+ `sknt.realloc(buf,n)` realloc函数会先检查buf，确保是否需要重新分配内存

+ `sknt.append(buf,data)` 简化了 `realloc` 和 `copy` 的操作。

+ `sknt.free(buf)` 释放一段内存，为了兼容`slab`，要求释放的是 buf(0)这个位置