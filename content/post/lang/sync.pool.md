---
title: sync.pool
date: 2022-04-15
tags: ['sync.pool']
categories: ['Go']
description: 
toc: true
draft: false
---



# 结构分析

```go
type Pool struct {
	noCopy noCopy

	local     unsafe.Pointer // P 本地池，固定尺寸，实际结构 [P]poolLocal，类似 void* 并附加长度构成了一个数组
	localSize uintptr        // size of the local array

	victim     unsafe.Pointer // local from previous cycle
	victimSize uintptr        // size of victims array

	New func() any
}

type poolChain struct{
    head *poolChainElt

    tail *poolChainElt
}

type poolChainElt struct{ // 一个双向链表
    poolDequeue

    next,prev *poolChainElt
}

type poolDequeue struct{
    headtail uint64

    vals []eface
}

type eface struct{  // 数据的真实内存分配，包括一个类型描述和实际数据
    typ,val unsafe.Pointer
}

type poolLocalInternal struct{
    private any // p的私有缓冲区

    shared poolChain // 公共缓冲区
}

type poolLocal struct{
    poolLocalInternal

    pad [128-unsafe.Sizeof(poolLocalInternal{})%128]byte  // 应该是补位，可以确保刚好占满一个 cache line 加速访问
}

```



# 申请释放

```go

func (p *Pool) pin() (*poolLocal, int) {
	pid := runtime_procPin() // 将当前G和P绑定，并返回P的id
	s := runtime_LoadAcquintptr(&p.localSize) // load-acquire
	l := p.local                              // load-consume
	if uintptr(pid) < s {  // 主要是P的数量可能会变动 重新找一个
		return indexLocal(l, pid), pid
	}
	return p.pinSlow()
}

func (p *Pool) pinSlow() (*poolLocal, int) {
	runtime_procUnpin()  // 禁止 P 抢占，否则当前G会被放回本地或者全局队列，当时之后G不一定在现在这个P上
	allPoolsMu.Lock()
	defer allPoolsMu.Unlock()
	pid := runtime_procPin()
	s := p.localSize
	l := p.local
	if uintptr(pid) < s { // double check
		return indexLocal(l, pid), pid
	}
	if p.local == nil {  // 如果本地队列为空，那么此时Pool没被初始化，加入全局池引用
		allPools = append(allPools, p)
	}

	size := runtime.GOMAXPROCS(0) // 查看现在P的个数
	local := make([]poolLocal, size) // 为这个Pool分配跟P数量相同的本地池
	atomic.StorePointer(&p.local, unsafe.Pointer(&local[0])) // store-release
	runtime_StoreReluintptr(&p.localSize, uintptr(size))     // store-release
	return &local[pid], pid // 返回当前和P绑定的本地池
}

func (p *Pool) Get() any {
	if race.Enabled {
		race.Disable()
	}
	l, pid := p.pin() // 先找本地池
	x := l.private
	l.private = nil
	if x == nil { // 如果没有，那么从全局池找
		// Try to pop the head of the local shard. We prefer
		// the head over the tail for temporal locality of
		// reuse.
		x, _ = l.shared.popHead()
		if x == nil {
			x = p.getSlow(pid)
		}
	}
	runtime_procUnpin() //释放P，让其可以被抢占
	if race.Enabled {
		race.Enable()
		if x != nil {
			race.Acquire(poolRaceAddr(x))
		}
	}
	if x == nil && p.New != nil {
		x = p.New()
	}
	return x
}


// Put adds x to the pool.
func (p *Pool) Put(x any) {
	if x == nil {
		return
	}
	if race.Enabled {
		if fastrandn(4) == 0 {
			// Randomly drop x on floor.
			return
		}
		race.ReleaseMerge(poolRaceAddr(x))
		race.Disable()
	}
	l, _ := p.pin() // 老规矩，先禁止P被抢占
	if l.private == nil { // 本地没有 则先放入本地
		l.private = x
	} else {
		l.shared.pushHead(x) // 否则放入全局
	}
	runtime_procUnpin()
	if race.Enabled {
		race.Enable()
	}
}
```


# GC

> 其实很好理解，正好是一次二级缓冲模型，第一次gc会将local放入 victim，第二gc victim不为空才会真正清理，local不会参与gc

```go
func poolCleanup()
	for _, p := range oldPools {
		p.victim = nil
		p.victimSize = 0
	}


	for _, p := range allPools {
		p.victim = p.local
		p.victimSize = p.localSize
		p.local = nil
		p.localSize = 0
	}
	oldPools, allPools = allPools, nil
```