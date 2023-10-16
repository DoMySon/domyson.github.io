---
title: conf
date: 2022-12-17
categories: ['skynet']
description: 
toc: true
draft: false
---



# skynet config

> 在1.4.0版本之前，类似于skynet，是通过一个lua来作为配置文件启动的，但之后实现了一个高性能的ini解析器来作为配置加载器，好处是可以省略一个类似 `launcher` 的 LuaState。并且加载速度更快

## example

```txt
# 修改当前节点的 work directory
root = ./example

# go插件的搜索路径，特别注意的是它仅仅是将它作为一个服务启动，这本不同于lua
plugin_path = ./


# 版本检查选项，若开启它则自动会检查版本是否匹配，版本是通过编译指令设置的。
#version = "1.3.1"

# 以后台进程的方式启动
#daemon = "./skynet.pid"


# 这个节点不是 sknt 标准选项，需要注意的是 lua模块是一个可编译选项，而不是 sknt自带的
[lua]
path=./cop/?.lua;
# other go written lua module
plugin_path = ./lua_plugin
# launch first scritp
main = pool


# 集群选项
# [sknmpd] 
#     name = "node1"  # can use follwing hosts value.  ":port  ip:port"
#     cookie= "hello world"  # defualt the skynet version.


# 当前节点全局环境变量设置，通过 sknt.getenv(key) 来获取值
[env]
node1 = 192.168.2.31:3002
node2 = :3003
node3 = hello world


# 是否开启控制台
[console]
# 地址可以是内网或者外网
addr = :8080
# 链接密码或者ca文件（用来定义是否走 tls)
token = abcd

# 日志配置
[log]
# 日志输出文件位置，若dameon被设置，这个值也是必要的，否则将作为 stdout输出，一般是terminal
#path = "skynet.log"
# 日志输出标志
flags = 127
# 调用栈深度，一般为0～2
# depth = 0
# 日志缓冲区，取决于pci管线的带宽，有助于提升性能，也会带来输出延时，0则为立即输出
# buffered = 4096
# 日志头标识
# prefix= "anyhting"
```