---
title: Go GC分析
date: 2022-02-26
tags: ["GC"]
categories: ["go"]
description: go 内置命令
img: https://www.runoob.com/wp-content/uploads/2015/06/go128.png
toc: true
draft: false
---


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


# memory barrier

> 保障了代码描述中对内存的操作顺序，`即不会在编译期被编译器进行调整，也不会在运行时被CPU的乱序执行所打乱`

## write barrier

在应用进入 GC 标记阶段前的 stw 阶段，会将全局变量 runtime.writeBarrier.enabled 修改为 true，这时所有的堆上指针修改操作在修改之前便会额外调用 runtime.gcWriteBarrier

由于GC和Go主程序并发执行，所以必须要在扫描时监控内存可能出现的状态改变，所以需要写屏障，所以需要暂停GO主程序（STW）



## hybrid wirte barrier (after go1.8)

> 改方式的基本思想是：对正在被覆盖的对象进行着色，且如果当时栈未扫描完成，则同样对指针进行着色


# GC流程

程序启动会为每个P分配一个 mark worker 来标记内存，负责为进入STW做前期工作

+ 起初认为所有 object 都被认定为白色
+ 但栈，堆和全局变量的object被标记为灰色

GC会将灰色object标记为黑色，将灰色object所包含的所有指针所指向的地址都标记为灰色，递归这两个步骤，最终对象非黑即白，其中白色object即未被引用且可以被回收，如果object标记为no scan，则递归结束，标记为黑色


todo https://blog.csdn.net/asd1126163471/article/details/124113816