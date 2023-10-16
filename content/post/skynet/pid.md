---
title: pid
date: 2022-04-21
categories: ['skynet']
description: 
toc: true
draft: false
---


# PID

`Pid` 是当前服务的唯一id，它确保在当前节点以及集群中唯一。

但重新启动节点之后，它的值可能会发生改变，所以不要尝试保存它，但可以确定的是集群中它依然是唯一的



# 作用

表示某一节点的某一的服务的地址，它最终输出是一串 uint64 的值。

可以通过 `skynet.send(dst,...)` `skynet.call(ti,dst,...)`来使用它，将消息发送出去