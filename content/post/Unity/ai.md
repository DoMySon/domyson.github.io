---
title: 组合AI
date: 2019-12-10
tags: [""]
categories: ["unity"]
description: 
toc: true
draft: false
---



#  什么是AI

+ 一串由外部因素影响行为的实体？

+ 内部条件分支构建的行为？

+ 学习并采取对应策略的结果？（Alpa go）


# AI设计思想

> 特别注意这是笔者自己的一套思维，而非网上流传的。其中会混入一些ECS的思想

## 何谓AI

我们人为给它制定约束行为条件，让其结果收敛于某个区间，比如我没给它赋予行走的行为（单元），那么它就不应该存在这种方面的意向倾斜，（它可能会提示需要这种行为，而不是自主产生这种行为），这也是和带学习能力AI的区别，它的计算结果不应该是发散的。

## AI Unit

AI单元是对某些行为具体抽象，它是数据（你也可以认为它是ECS中的C），比如行走（AI_WALK），它有一些数据
```csharp
public class AI_Walk{
    public float Speed;

    public Vector3 Direction;
}
```

这个时候AI实体具备了一个行走的逻辑，朝哪走，走多快由这个单元确定，再比如说跑这个行为，它和走没任何区别，我们仅仅需在必要的时刻改变`AI_Walk`这个单元的属性值即可。因为它们有共同的数据结构。


## AI Selector

AI选择器用于对每个条件节点


## AI Executor


todo