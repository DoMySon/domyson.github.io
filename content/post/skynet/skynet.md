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

与`skynet-c`的区别可见(暂未统计) [diff-skynet](/post/diff)


<!--more-->

# 设计概述

+ 过往的工作中曾经开发了一个`cobweb`的分布式服务器框架（基于`golang`,`c`）,但是在实际开发过程中代码难以维护以及更新，主要是每次都需要跨平台进行编译，特别是`cgo` 往往需要指定平台的系统库,而且一些不规范的使用方式造成无法充分发挥多核的优势，可以参见 `关于Go协程的思考` 虽然1.16 支持抢占式，但错误的使用方式依然造成了cpu过高的问题。


+ 再者，服务器过多的 `goroutine` 被创建，极大浪费了内存以及cpu。我不希望滥用协程，其代价比预估的要高。

+ 由于以上目的，重写了`cobweb` 的底层，底层对用户不再透明。而是通过脚本语言导出来提供支持

+ 这里强调一点，`skynet-go` 设计类似于 `skynet`，但极大部分全由底层语言实现，而`Lua`更像是一个命令，也类似现在规则引擎的概念，这也是和 `skynet` 最大的区别，它没有任何多余的`Lua` 代码。甚至于它也提供其它脚本语言的接口，`可参见 [scriptc](/post/scriptc/1)`


# 特性
  1. 支持纯`Lua`编码， 原因在于 `lua` 是一门简单并且性能很高的脚本语言，能显著降低开发成本，而且`skynet-go`本身提供了丰富的接口

  `pure go`或者`cgo`也同样支持,而且性能会更好

  后续会替换新的脚本语言 [scriptc](/post/scriptc/1)

  2. mysql,redis,mongo dbserver 支持

  值得注意的是这些库都是作为第三方写的，跟主库关联不大，一般需要编译时指定，特别是`Lstate`的版本要求一致

  3. 提供`tcp` `udp`,`unix`支持

  4. 内置集群组件 [sktpmd](/post/skynet/sktpmd),做平了本地和远程的调用界限

  5. 重新实现的http框架，区别于 `net/http`,仅仅实现部分 `RFC` 标准,兼容此框架的网络库，提供更好的性能
  
  6. 隐藏的数据编码，对业务不透明，基与比`protobuf-v3` 更快的编码 [kproto](/post/kproto)

  7. 无任何lua模块,仅有一个执行文件和一个配置文件


# 架构

+ `skynet-go` 是函数式以及低抽象的架构,纯函数式主要是受 `c` 的影响。纯函数也更贴合职责单一的原则,而低抽象是因为`go interface` 并非零成本抽象，它有一定的性能代价。所以整个`skynet` 只有一个接口 `Freeable` 用以标记需要自动释放的对象。

+ `skynet-go`仅需要一个执行文件，大小仅仅`5.78mb`,默认运行内存仅仅 `2.2mb`，

+ `65535 Lua`服务仅占用`1.8GB`,也就是每个 `Lua服务` 仅占用 `28.8kb`

+ `65535 pure go`服务仅占用`120mb`,每个`pure go`服务仅占用 `1.9kb`




{{< adsense-footer>}}
