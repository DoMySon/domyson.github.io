---
title: kproto 编码协议
date: 2022-09-21
tags: ['']
categories: ['']
description: 
pin: true
toc: true
draft: false
---

# 前言

其实在`cobweb`之初就设计了一种编码协议(kproto)，用于内部消息的编码,但因为公司项目长期需要维护以及开发（两款线上，一款开发中），所以一直未对此库进行维护，
而后期在研发的时候，发现需要与多种语言交互，显然 `json`,`xml` 不是一个很好的选择，而 `protobuf` 对弱类型语言支持不友好。

# Benchmark

- cpu: Intel(R) Core(TM) i9-9900K CPU @ 3.60GHz
- os: windows11
- arch: amd64

format|compress rate|encode rate|decode rate
|:-:|:-:|:-:|:-:|
json std|0%|0%( 213.8 ns/op)|0%(1204ns/op)
proto v3|-40%|-51%(98.36 ns/op)|-84%(190.1ns/op)
kproto|-40%|-76% (65.21 ns/op)|-95%(62.18ns/op)

<!--more-->

# Feture

+ 快速，比`protobuf-v3` 基本高出 `20%`左右

+ 简单，文件生成方式不是必须的，也是动态设置

+ 小体积 基本编码后的二进制与`protobuf`持平

+ 流式 它可以直接读取任意字段而不需要解析出所有字段

+ 多语言支持 提供了完整的`golang`和`c`实现，在`skynet-go` 中也是默认编码协议，所以对`Lua`提供了支持

+ 干净 没有任何隐式内存分配，由外部指定分配器

+ 无冗余 可以通过`sizeof`直接获取需要的内存大小，避免多余的内存浪费


# 词法解析器

+ 因为需要和强类型和弱类型进行转换，词法解析器和描述文件需要一个抽象共用类型加以识别，所以对于强类型语言是通过生成描述文件识别的。

+ Lua5.1 是没有整数类型，需要区分浮点和整形的区别，这涉及到最终编码的尺寸，kproto对它们进行了区分

+ Lua table 纯数组table和hash table 的编码方式也是不同的，这依赖于 table 在底层的结构，若非必要不要混合。


# 代码生成器
    
1. 强类型和弱类型的识别是有很大区别，所以我对`Lua` 这边进行了直接解析，简单来说是直接通过 `Lexer` 生成此消息结构的元信息.

2. 强类型语言为了减少反射，我们需要通过文件描述来提供其成员或字段的类型以及位置而非通过反射，这个在编译期间就可以确定了而非运行时。

3. 此模块在当前进程中的所有服务是生效的


## 设计思路

1. 减少内存分配

    为了减少i/o和内存压力，最简单的办法是让一个字节能包含更多的消息， 如一个32bit的整形，它真的需要4byte的字节空间吗？,其二不同的分配大小影响执行速度，（如32byte和64kb 是存在明显区别），
    所以需要动态计算分配尺寸。

2. `unsafe.Pointer`
    
    显然反射是所有带运行时语言的一个痛点，而通过 `unsafe.Pointer` 能明显提高执行速率，所以 `kproto` 采用了大量非安全指针操作，所以关于生成文件尽量不要进行任何编辑，以免造成内存偏移位置错误。


3. interface

    当然在 `kproto` 设计之初是没有考虑嵌套消息的，其他方式亦可实现，因为这会加大分析负担，而实际情况恰恰相反，消息嵌套是实际业务中必不可少的一部分，它明显降低了技术门槛，

    因为但go语言的接口本质上是两个指针（其一指向类型系统，其二指向该类型的具体方法），为了能够指针能正确到的索引到指定类型，我们需要一点点反射来支持（这个只会在启动时运行，大可不必担心）。

3. 在`lua`中使用
    ```lua
    local kproto = require("kproto")
    local err = kproto.load("file path or dir path")  -- 注意 此函数执行结果在当前节点是共享的，所以只需要加载一次，并返回一个错误（string）
    if err~=nil then
        -- do something
    end
    -- 此时返回的data是 `userdata`,不要尝试访问它
    local data ,err = kproto.marshal(string,table)

    -- 仅返回一个错误，并将具体数据映射到传入的 `table` 中
    local err = kproto.unmarshal(string,data)  
    ```


4. kproto

> kproto 支持两种模式，其一类似`.proto`文件，定义模板，其二直接使用库进行解析

```txt
package gen   // 区分同名消息
// 注释

enum Foo {  // 一个枚举，最终会转换为 uint32 类型进行编码
    A : 0
    B : 1
    C : 2
}

message empty {}  // 一个空消息

message PhoneNumber{  
    string number : 0 

    integer type : 1  // 整形的抽象类型，具体编码和长度取决于当前语言，包含(i16,u16,i32,u32,i64,u64)

    float f : 2       // 浮点的抽象类型，具体编码和长度取决于当前语言 (f32,f64)
}

message Person{
    string name : 0
    integer id : 1
    string email: 2

    *PhoneNumber phones : 3  // 嵌套类型的数组

    PhoneNumber phone : 4  // 嵌套类型
}


message AddressBook {
    *Person person : 0
}
```


## Lua 序列化

- `kproto` 开发过程的附加产物，唯一的区别仅能在`lua`侧使用,不支持`userdata`,`function`,`thread`

- `kproto` 产生的会导致新的内存分配，记得释放它，不然会造成GC

> 这里特别注明，`userdata`不支持仅仅是为了兼容节点通讯。因为它本质上一个8byte的整形(x64),而其他物理机或者进程的内存地址是不同的



# excel 数据表支持 
> 惰性加载，数据表索引，二进制编码

[datatable](/post/datatable)

# 未来将支持

+ `rpc` 定义

+ 指定字段偏移解码（beta）


{{< adsense-footer>}}
