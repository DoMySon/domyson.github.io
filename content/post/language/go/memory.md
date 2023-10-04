---
title: Go Memory
date: 2022-10-07
tags: [""]
categories: ["Go"]
toc: true
draft: false
---


# 虚拟内存

> 虚拟内存屏蔽了`RAM`和`Disk`,向进程提供远大于物理内存的内存空间，简单来说就是使用了 `memory map` 分别映射了`RAM`和`Disk`的某个区域



# 堆栈

> 栈的方向向低地址增长，而堆恰好相反

```text
Vritual memory address

    |       kernel      |
    |-------------------| 0xC00000000
    | ---argv,evniron---|
    | -------stack -----|
    | ---------↓--------|
    | ----stack top-----|
    |                   |
    |    unallocated    |
    |       
    |        heap       |
    |
    | uninitialized data|
    | initialized data  |
    |   program Code    |
    |                   | 0x08048000
    |                   | 0x00000000   
```



# `Tcmalloc` 

> 也许同时`google`出品吧

+ Page

    操作系统对内存管理以页为单位，`Tcmalloc` 也是如此，但其不一定相等，而是倍数关系(x64 Page 为8kb)

+ Span

    一组连续的`Page`称为`Span`,是`Tcmalloc`的基本单位

+ ThreadCache

    每个线程自身的`Cache`,包含多个空闲内存块链表，每个单独的链表大小是一致的，方便申请时不需要遍历全局，而且是无锁访问

+ CentarlCache

    所有线程共享的空闲内存块，链表数量同 `ThreadCache`,当`ThreadCache`不够时会从其申请，但它是需要加锁

+ PageHeap

    对堆内存的抽象，也是由若干链表组成，链表保存的是 `Span`，当 `CentarlCache`不足时，获取空闲`Span`然后拆分成若干内存块，并添加到对应大小的链表中以供分配，否则将会放回


## 对象大小

    小对象: 0~256kb
    中对象: 257kb~1mb
    大对象: > 1mb


# Go内存模型

+ Page
    
    同 `Tcmalloc Page`

+ Span
    
    同 `tcmalloc span`

+ mcache

    类似于 `tcmalloc ThreadCache`,区别在于前者和线程绑定，后者和golang的 `P` 绑定

+ mcentral
    类似于 `tcmalloc CentarlCache`，用以mcache空间不够时从这里申请
    
+ mheap

    类似于 `tcmalloc pageheap` ，当初始化一个大对象时，直接走 heap 分配，go后期版本叫做 `arenas`

## 对象大小定义

    > golang 并未区分为大中小对象，而是区分为 tiny，小，大，如 tiny[1byte,16byte),并且不包含指针,小对象为[16b,32kb],大对象 > 32kb
    


# 逃逸分析

> go build -gcflags="-m"