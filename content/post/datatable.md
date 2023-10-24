---
title: datatable
date: 2023-09-17
tags: ['']
categories: ['']
description: 
toc: true
draft: false
---


# 前言

`datatable` 使一个转换并加载excel数据表的库，它基于 [kproto](!/post/kproto)



# 原理

在解析原始 `excel`数据的时候会先生成两中中间数据

1. `metadata` 元数据

它用来描述此数据单元的结构，类型以及尺寸

2. `values` 数据

它以`excel` 行的形式存储真实数据 （数据表中未注释，并且有效的数据）

{{< adsense-footer>}}
