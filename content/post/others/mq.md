---
title: 消息队列
date: 2022-04-11
tags: ['mq']
categories: ['others']
description: 
toc: true
draft: false
---


它的本质，就是个转发器，包含发消息、存消息、消费消息的过程



# 优势

+ 应用解耦
+ 流量削峰
+ 异步处理
+ 通讯


# 削峰

当某个系统处理为n时，而此时请求量为 m*n 时，系统可以每次从mq中拉出n个依次处理



# 实现一个消息队列  [sknt](/post/sknt/message)