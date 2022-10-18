# ukn-scheduler





# 调度器以及调度规则

分为两个部分,`lua`和`go`



## Lua

lua本质上是一个单线程的语言，天生不支持多线程，而在ukn框架中我们需要让它能够模拟类似于`中断`之类的操作，io等待的操作，

+ 我用上下文持有来保存当前`coroutine`,而不需要保存一个等待列表，并且此时对业务而言这个是不透明的，所以减少了维护负担

+ 其次就是满足`异步coroutine`，它底层会在其他`goroutine`中运行，但是不会出现数据race

+ 兼容了ukn的api设计

## 

`ukn.fork(function)` `ukn.yield`,`ukn.sleep(millilsceond)`
