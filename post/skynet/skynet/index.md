# skynet设计初衷以及特性




# 简介

skynet是一个基于`go` 分布式服务器框架,灵感来自于`skynet` `erlang`.


# 设计目的

工作中开发一个分布式多人在线游戏的时候构建了一个`cobweb`的分布式通讯框架（基于`golang`,`c`）。

但是在实际开发过程中代码难以维护以及更新，主要是每次都需要跨平台进行编译，特别是`cgo` 往往需要指定平台的系统库。

而且一些不规范的使用方式造成无法充分发挥多核的优势，可以参见 `关于Go协程的一些思考` 虽然1.16 支持抢占式，但错误的使用方式依然造成了cpu过高的问题。

再者，高并发服务器会造成过多的 `goroutine` 被创建，极大浪费了内存以及cpu。

基于以上目的，期望能对`cobweb` 进行一些更高程度的封装，以及底层重写。 所以 `skynet` 被设计了出来。

虽然与云风大神的`skynet` 同名，但调度方式以及绝大部分api的使用方式是有很大区别的,并且不包含任何lua库，（包括但不限于协程池）





# 特性

  1. 支持 `cgo` 沿用自 `cobweb`
  2. 支持 `plugins`，为了方便从外部直接加载以满足热更新需求 `unix only`
  3. 支持纯`go`,当然这是一句废话
  4. 支持 `lua` 原因在于 `lua` 是一门简单并且性能很高的脚本语言，而且业务开发的成本会被降低
  5. mysql支持，dns支持，http支持


# 区别（后续完善）

  1. 集群通讯，`skynet.send`,`skynet.call` 抹平了本地和集群的区别，不存在 `cluster` 这个命名空间或者库
  2. lua 序列化，编码格式完全区别与 `lua-seri.c`。
  3. sproto 当前支持 `go` `csharp` `lua`,测试性能高于 protobuf 15%左右，后续对应文章会单独贴出
  4. 纯go实现的http框架，区别于 `net/http`,仅仅实现部分 `RFC` 标准
  5. 支持同步调用超时
  6. 内置消息订阅，也支持 `nats` （一个简单的封装）并不保证线上项目的稳定性
  7. 消息发送默认都是指针，如有需要，可通过一些api来copy，并提供 `skynet.free` 方法来释放它。



# API



# 架构










# 版本历史


# v1.1.1

## Fixed
- 修复了`http`一个原子锁问题，但在高并发下可能会出现失败的情况
- 修复了 `skynet.send(string,any)` 会产生两次搜索的情况

## Added
- skynet-lua 增加 `syknet.trace()` 用以输出当前堆栈
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

- 现在 `skynet.warn`,`skynet.error`,`skynet.trace`,`skynet.debug` 支持传入任意类型参数

## Fixed

- 修复了`cluster`消息无法被释放的bug

## Add

- 增加 `skynet.call` `skynet.reply` 是一个组合调用。否则会造成协程被挂起


# v1.2.2

## Add

- 增加 `sproto` 协议解析，通过 `sproto = require("skynet.sproto")` 引用
- `sproto`
  - `errno = sproto.parse(path)` 解析文件描述
  - `bytes(usrdata),errno = sproto.encode(string,tab)` 按指定文件编码`table`
  - `tab,errno = sproto.decode(string,bytes(userdata))` 按指定文件解码 `bytes` 解码为 `table`


## Fixed

- 修复`skynet.call` 的一个状态判定问题



# v1.2.3

## Fixed

- 修复`http`的一个判断bug

- 优化`cluster`传输逻辑，以及连接逻辑

- `skynet.call` 现在支持远程调用



# v1.2.4

## Fixed

- 集群减少了每条连接 `64byte` 的额外分配

- 缩减了调用方法深度

- 减少了类型断言的次数


#v1.3.1

todo
