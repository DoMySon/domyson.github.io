---
title: TopK
date: 2019-07-31
tags: ["TopK","Sort"]
categories: ["算法"]
toc: true
draft: false
---


# 问题 

> 在一堆数据里面找到前 K 大（也可以是前 K 小）的数。本文对于三个算法 `QuickSort`、`HeapSort`、`BubbleSort` 来比对


# 全局排序

> 使用 `QuickSort`、`HeapSort`、`BubbleSort` 进行全局排序，然后取前 K 个或后 K 个。时间复杂度随排序算法而定


# 局部排序

> 基于上一个问题，对于前 K 个数来说，后面的排序与否其实不重要，只需要排序前 K 个，那么首先算法必须是稳定排序，`BubbleSort` 是稳定排序算法，通过冒泡 K 次即可得到结果。时间复杂度 `O(n*K)`

# 堆

> 那么对于前 K 个数它们的排序与否也不重要，只要大于后面的数即可，那么只需要前 K 个元素构成一个小顶堆，然后遍历剩下 n-K 个元素，再调整堆，保证这个堆所有元素均大于等于剩下的 n-K 个元素即可。时间复杂度为 `O((n-K)logK)`


# 减治算法

> 与分治算法不同的是：减治算法是将问题分为若干个子问题，只要其中一个子问题得解，那么这个问题整体得解，比如二分查找法 `BinarySearch`。时间复杂度为 `O(K*log(n))`

```go
/*
    二分查找法的缺陷是要么数组是有序的，要么得知道具体目标值
*/
func BinarySearch(arr []int,low,high,target int) int{
    if low > high {
        return -1
    }
    mid := (low+high)/2
    if arr[mid] == target {
        return mid
    }
    if arr[mid] > target {
        return BinarySearch(arr,low,mid-1,target)
    }else{
        return BianrySearch(arr,mid+1,target)
    }
}   
```