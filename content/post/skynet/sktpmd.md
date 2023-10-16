---
title: sktpmd
date: 2022-05-30
tags: ['sktpmd']
categories: ['skynet']
description: 
toc: true
draft: false
---


# 简介

`sktpmd`模块是`skynet`底层集群模块，它承担了`skynet`网络节点之间的通讯职能。全名为(`skynet port managment daemon`)


# 架构

1. `sktpmd` 为了满足对等网络的性质，所以每次和其他节点建立连接是有两条连接，
    当A节点于B节点建立连接，首先A节点发送握手等待B确认，B确认完成之后重复走A的流程，这样一个双向连接就被建立了起来

2. `sktpmd`可以支持任意网络协议，如 `tcp`,`udp` 甚至是 `unix`

3. 当然一个好记的节点名称是非常有必要的，所以`sktpmd`也内置了一套非标准的本地 `dns`系统


# 使用

`sktpmd`的启动也非常简单，无须任何代码，仅仅只需要在 `skynet.toml` 中配置一下即可，使用的时候跟节点内通讯无任何区别，但要求参数必须是 `[]byte` 类型，参考 [bbuf](/post/skynet/bbuf)
如

```lua
skynet.send("host:port@name",...) -- 通过域名或者地址+端口的形式和其他节点进行通讯
skynet.send(pid,...)              -- 通过pid亦可
```


# ~~tunnel~~

既然节点之间是双向连接，所以连接数量为 `f(n) =  n²-n`，如果节点过的时候，势必造成 `socket fd` 消耗殆尽，

基于这个问题，可以通过内置的`tun`，来设置代理，这么一来，`tun`的作用相当于这个集群节点的网关。因为其内部的节点相对于其他 `tun` 代理是不可见的，

通过配置`tun`的规则开启多个，则可以实现业务拆分。

 > 2022-10-07 此模块被弃用，可以用多节点转接的方式或代理的方式做到，如 `send("n1.n2.n3@name")`


# 服务发现

`sktpmd` 提供了一套服务发现机制，但其运作原理是不同于 `etcd` 或者 `consul`,它本身是一个惰性发现，取决于第一次调用的地址是否正确返回。

你不需要知道它是如何运作的，你只需要知道在特定时间内它是有效的即可，那怕其中出了一些意外，无非只是浪费了两次通讯而已。

## gossip

> sktpmd整个发现流程是基于 `gossip` 算法来发现的,但一些api依然可以主动触发

# 网络底层

参考 [Go协程的思考](/post/language/go/goroutine),在`linux`下，使用了 `epoll`。所以尽量部署到 `linux` 下以发挥更好的性能