---
title: skynet-go 设计初衷以及特性
date: 2022-06-20
categories: ['skynet']
description: 
toc: true
pin: true
draft: false
---



# 概述

> `skynet-go` 是一个基于消息和服务的`Actor`分布式服务框架，
采用`go`编写，致力于简化开发难度和成本。

它是一个年轻的框架，仅仅经历了两款项目的迭代 现在版本为 `v1.6.0 2023-05-28` 
- [羽翼军团](https://www.taptap.cn/app/229839) v1.3.0
- [我在民国淘古玩](https://www.taptap.cn/app/215934) v.1.3.5

至于什么是`Actor`是必要了解的概念，[skynet](https://github.com/cloudwu/skynet) 以及 `erlang` 都是基于这种模式。

与`skynet-c`的区别可见 [diff-skynet](/post/diff)


<!--more-->

# 设计概述

工作中开发一个分布式多人在线游戏的时候构建了一个`cobweb`的分布式服务器框架（基于`golang`,`c`）。

但是在实际开发过程中代码难以维护以及更新，主要是每次都需要跨平台进行编译，特别是`cgo` 往往需要指定平台的系统库。

而且一些不规范的使用方式造成无法充分发挥多核的优势，可以参见 `关于Go协程的思考` 虽然1.16 支持抢占式，但错误的使用方式依然造成了cpu过高的问题。

再者，服务器过多的 `goroutine` 被创建，极大浪费了内存以及cpu。

基于以上目的，重写了`cobweb` 的底层，底层对用户不再透明。 所以  被设计了出来。


尽管如此，一些高性能模块还是由 `cobweb` 承载的，因为lua本身语言的设计还是会有些先天性缺陷。


# 特性

  1. 支持 `cgo` 沿用自 `cobweb`
  2. 支持 `plugins`，为了方便从外部直接加载以满足热更新需求 `unix only`
  3. 支持纯`go`,当然这是一句废话
  4. 支持 `lua` 原因在于 `lua` 是一门简单并且性能很高的脚本语言，能显著降低开发成本
  5. mysql支持，dns支持
  6. 提供`tcp` `udp`,`unix`支持
  7. 不特别区分远程或者本地调用 `skynet.send`,`skynet.call` 抹平了本地和集群的区别 
  8. 实现的http框架，区别于 `net/http`,仅仅实现部分 `RFC` 标准,兼容此框架
  9. 消息发送默认都是指针，如有需要，可通过一些api来序列化，并使用 `skynett.free` 方法来释放它。
  10. 无任何lua模块，(除去[拓展模块](/post/thrid)),仅仅一个 `5mb` 左右的执行文件

# [sknmpd](/post/skynet/sktpmd)

> 在`skynet-go`中每个节点都是平等的，不存在谁依赖于谁，这也是`cobweb`的设计初衷。所以`skynet` 不支持 master/slave 模式，但可以通过业务代码来实现，而非框架本身。



# 架构

`skynet-go` 是函数式以及低抽象的架构

纯函数式主要是受 `c language` 的影响。也更贴合职责单一的原则

而低抽象是因为`go interface` 并非零成本抽象，它由一定的性能代价。所以整个`skynet` 只有一个接口 `Freeable`。


# 运行

`skynet-go`仅需要一个执行文件，大小仅仅`6.8mb`,而运行内存仅仅 `2.4mb`，65535个Lua服务仅占用`1.8GB`,也就是每个 `Lua服务` 仅占用 `28.8kb`,如果是`go`服务那么将会更小


{{< adsense-footer>}}
