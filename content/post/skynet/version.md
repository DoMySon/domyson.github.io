---
title: version change
date: 2022-04-30
categories: ['skynet']
description: 
toc: true
draft: false
---


# v1.1.1

## Fixed
- 修复了`http`一个原子锁问题，但在高并发下可能会出现失败的情况
- 修复了 `skynet.send(string,any)` 会产生两次搜索的情况

## Added
- skynet-lua 增加 `skynet.trace()` 用以输出当前堆栈
- skynet-lua 增加 `check_version()` 函数，校验skynet版本



# v1.1.2

## Fixed 

- 修复了`kill`函数重入导致越界的问题

- 修复`http` 因为判断发送失败的错误，现在如果发送失败返回404

## Mod

- `skynet.send(dst,...)` 现在传入参数可以是大于2个，当等于2，与之前无区别，当大于2则会转为`table`
- `skynet.send()` 现在不返回 `boolean`，而是返回一个`number`,为`0`则认为成功
- `kill` 函数现在会立即退出当前服务
- `killed` 事件不会被传入了




# v1.2.0

## Mod

- 取消了事件投递到达服务，会给出一个字符串类型的消息发送这类型，用以区别数据的来源位置以及类型

- 与上述相关的问题，`skynet.send(dest,...)` 变为了 `skynet.send(dest,typ,...)` 现第二参数输入你自己的类型，以便于接收者区分，不要和服务同名，那是没有任何意义的
主要是为了确定一种数据的类型，而非一系列服务，本身服务和数据类型并非是一对一的关系


- `skynet.start` -> `skynet.uptime`



# v1.2.1

## Mod

- 现在 `skynet.warn`,`skynet.error`,`skynet.trace`,`skynet.debug` 支持传入任意类型参数,优化栈分配

## Fixed

- 修复了`ucpd` 缓冲未释放的问题

## Add

- 增加 `skynet.call` `skynet.reply` 是一个组合调用。否则会造成协程被挂起


# v1.2.2

## Add

- 增加 `bbuf` 协议解析，通过 `bbuf = require("skynet.bbuf")` 引用
- `bbuf`
  - `errno = bbuf.load(path)` 解析文件描述
  - `bytes(userdata),errno = bbuf.marshal(string,tab)` 按指定文件编码`table`
  - `errno = bbuf.unmarshal(string,bytes(userdata),tab)` 按指定文件解码 `bytes` 解码为 `table`


## Fixed

- 修复`skynet.call` 的一个状态判定问题



# v1.2.3

## Fixed

- 修复`http`的一个判断bug

- 优化`skynetcmd`传输逻辑，以及连接逻辑

- `skynet.call`,`skynet.send` 现在支持远程调用



# v1.2.4

## Fixed

- 集群减少了每条连接 `64byte` 的额外分配

- 缩减了调用方法深度

- 减少了类型断言的次数


#v1.3.1

todo


#1.3.6

todo


# 1.4.0

## ADD
- ini 解析器

- lua协程池

- lua-socket beta版本

## FIXED

- 修复 `skynet.call()` 会造成当前虚拟机全部阻塞的bug

## Modify
- 自动对消息类型分类

- 重构http

## Remove

- 删除 Alive(pid)

- 删除 `check_version()`