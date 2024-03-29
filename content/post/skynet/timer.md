---
title: timer
date: 2022-04-30
categories: ['skynet']
description: 
toc: true
draft: false
---


# 简介

`timer` 模块是 `skynet-go` 全局的一个计时系统，内部数据结构使用了小根堆实现。


# 原理

本质上是开启一个单独的协程执行一个计时循环，通过 `skynet.timeout(addr,ti,cb)` 将调用服务的`pid` 传入进去，等待以一个特殊的消息指令`EV_TIMEOUT` 通知到对应服务，所以它会具有一定的延时性，若该服务本身处理时间过长，导致`mailbox`消息积压过多，那么这个指令将会排队直到被处理，


> 需要注意的是，超时消息触发的时间没有问题，而是处理的时候有延时性


## 对lua的支持




# QA

1. 为什么不提供循环计时器？

    可以使用闭包来实现循环

2. 为什么不提供取消？

    可以使用标记位来控制逻辑

3. 为什么使用小根堆

    为了尽可能减少精度丢失，以及内存，简单而言其实是一个`topk`算法的变种，不需要在一次循环中做完所有事(10ms)