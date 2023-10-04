---
title: hash算法
date: 2022-08-30
tags: ["metatable"]
categories: ["lua"]
toc: true
description: 
---
# 非可逆加密

## MD5(Messgae-digest algorithm5)信息摘要
> 将任意长度的明文字符串生成 `128bit` 的哈希值，也为32个十六进制的数


## SHA(Secure Hash Algorithm)信息摘要

+ `SHA-1` 生成 `160bit` 的哈希值

+ `SHA-2`
    
    + `SHA-244`

    + `SHA-256`

    + `SHA-384`

    + `SHA-512` 


---

# 可逆加密


## AES(Advanced Encryption Standard)对称加密

+ `AES128`

+ `AES192`

+ `AES256`

### 模式
1. CBC模式：电码本模式 Electronic Codebook Book

2. ECB模式（默认）：密码分组链接模式 Cipher Block Chaining

3. CTR模式：计算器模式 Counter

4. CFB模式：密码反馈模式 Cipher FeedBack

5. OFB模式：输出反馈模式 Output FeedBack