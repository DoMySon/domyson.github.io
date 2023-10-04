---
title: iptables and ipvs
date: 2022-11-19
tags: [""]
categories: ["linux"]
description:
toc: true
draft: false
---


# iptables 

`iptables` 基于 `netfilter` 采用一条条规则链表，时间复杂度为O(n)，最主要的是 `iptables` 专为防火墙设计


# ipvs

`ipvs` 同样基于 `netfilter`，但底层采用的是hash表，索引复杂度为O(1)