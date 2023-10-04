---
title: kubernetes
date: 2022-12-11
tags: ['k8s']
categories: ['cloud native']
description: 
toc: true
draft: false
---


# 什么是k8s

> k8s是为容器服务而生的一个可移植容器的编排管理工具

# K8S实现了什么

+ 服务发现 （etcd)
+ 服务调度 （kube-scheduler）
+ 负载均衡  (service)
+ 服务自愈  (controller)
+ 服务弹性扩容
+ 横向扩容
+ 存储卷挂载 (volume)

## 调度

Kubernetes 可以把用户提交的容器放到 Kubernetes 管理的集群的某一台节点上去。Kubernetes 的调度器是执行这项能力的组件，它会观察正在被调度的这个容器的大小、规格。
比如说它所需要的 CPU 以及它所需要的 memory，然后在集群中找一台相对比较空闲的机器来进行一次 placement，也就是一次放置的操作。

## 自动修复

Kubernetes 有一个节点健康检查的功能，它会监测这个集群中所有的宿主机，当宿主机本身出现故障，或者软件出现故障的时候，这个节点健康检查会自动对它进行发现。Kubernetes 会把运行在这些失败节点上的容器进行自动迁移，迁移到一个正在健康运行的宿主机上，来完成集群内容器的一个自动恢复。


## 水平伸缩

Kubernetes 有业务负载检查的能力，它会监测业务上所承担的负载，如果这个业务本身的 CPU 利用率过高，或者响应时间过长，它可以对这个业务进行一次扩容。



## k8s架构

Kubernetes 架构是一个比较典型的二层架构和 server-client 架构。Master 作为中央的管控节点，会去与 Node 进行一个连接。
所有 UI 的、clients、这些 user 侧的组件，只会和 Master 进行连接，把希望的状态或者想执行的命令下发给 Master，Master 会把这些命令或者状态下发给相应的节点，进行最终的执行。



# Master节点

- Apiserver
    整个系统的对外接口，供客户端和其它组件调用，组件与组件之间一般不进行独立的连接，都依赖于 API Server 进行消息的传送

- Scheduler
    负责对集群内部的资源进行调度，如把一个用户提交的 Container，依据它对 CPU、对 memory 请求大小，找一台合适的节点，进行放置

- Controller manager
    负责管理控制器，第一个自动对容器进行修复、第二个自动进行水平扩张

- etcd
    是一个分布式的一个存储系统，API Server 中所需要的这些原信息都被放置在 etcd 中，etcd 本身是一个高可用系统，通过 etcd 保证整个 Kubernetes 的 Master 组件的高可用性。


# Node节点

> Node 是真正运行业务负载的，每个业务负载会以 Pod 的形式运行 

- Container
    如Docker，但值得注意是Docker不是容器，只是容器的创建工具

- kubelet
    主要负责监视指派到它所在Node上的Pod，包括创建、修改、监控、删除等

- kube-proxy
    实现service的通信与负载均衡

- Fluentd
    主要负责日志收集、存储与查询

- Service

## Pod
Pod 是 Kubernetes 的一个最小调度以及资源单元。用户可以通过 Kubernetes 的 Pod API 生产一个 Pod，让 Kubernetes 对这个 Pod 进行调度，也就是把它放在某一个 Kubernetes 管理的节点上运行起来。一个 Pod 简单来说是对一组容器的抽象，它里面会包含一个或多个容器。

- 最小的调度以及资源单元

- 有一个或多个容器组成

- 定义容器运行时环境（Command，环境变量等）

- 提供容器共享的运行环境（网络，进程空间等）

- Pod之间是有隔离性的

### Volume
Volume 就是卷的概念，它是用来管理 Kubernetes 存储的，是用来声明在 Pod 中的容器可以访问文件目录的，一个卷可以被挂载在 Pod 中一个或者多个容器的指定路径下面。
而 Volume 本身是一个抽象的概念，一个 Volume 可以去支持多种的后端的存储。比如说 Kubernetes 的 Volume 就支持了很多存储插件，它可以支持本地的存储，可以支持分布式的存储，比如说像 ceph，GlusterFS ；它也可以支持云存储，比如说阿里云上的云盘、AWS 上的云盘、Google 上的云盘等等。

- 声明容器可访问的文件目录

- 可以被挂载到 Pod 中一个或多个容器的指定路径下

- 抽象概念，可以支持多种后端存储，（本地，分布式，云存储等）


### Service

Service 提供了一个或者多个 Pod 实例的稳定访问地址。对于一个Deployment下的多个Pod，外部只需要访问`Service`即可，至于具体分配到哪个 Pod 由负载策略决定，哪怕其中一个Pod挂了，对外部而言感知不到

### Deployment
Deployment 是在 Pod 这个抽象上更为上层的一个抽象，它可以定义一组 Pod 的副本数目、以及这个 Pod 的版本。一般大家用 Deployment 这个抽象来做应用的真正的管理，而 Pod 是组成 Deployment 最小的单元。
Kubernetes 是通过 Controller，也就是我们刚才提到的控制器去维护 Deployment 中 Pod 的数目，它也会去帮助 Deployment 自动恢复失败的 Pod。
比如说我可以定义一个 Deployment，这个 Deployment 里面需要两个 Pod，当一个 Pod 失败的时候，控制器就会监测到，它重新把 Deployment 中的 Pod 数目从一个恢复到两个，通过再去新生成一个 Pod。通过控制器，我们也会帮助完成发布的策略。比如说进行滚动升级，进行重新生成的升级，或者进行版本的回滚

- 定义一组Pod的副本数量，版本等信息

- 通过 Contorller 维持 Pod 的数目，自动恢复失败的 Pod

- 通过 Controller 制定策略版本控制。（滚动升级，重新生成，回滚等）



### Namespace
Namespace 是用来做一个集群内部的逻辑隔离的，它包括鉴权、资源管理等。Kubernetes 的每个资源，比如刚才讲的 Pod、Deployment、Service 都属于一个 Namespace，同一个 Namespace 中的资源需要命名的唯一性，不同的 Namespace 中的资源可以重名。

- 集群内部的逻辑隔离机制（鉴权，资源额度等）

- 每一种资源都应属于一个 Namespace

- 同一个Namespace 中的资源应当唯一

- 不同的 Namespace 的资源可以重名

# 优势

采用容器之后，很可能只需要一台服务器，创建十几个容器，用不同的容器，来分别运行不同网元的服务程序。

这些容器，随时可以创建，也可以随时销毁。还能够在不停机的情况下，随意变大，随意变小，随意变强，随意变弱，在性能和功耗之间动态平衡。


# [参考](https://zhuanlan.zhihu.com/p/150197380)