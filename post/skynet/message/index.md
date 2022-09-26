# skynet message





# 简介

`skynet`是基于消息的服务框架，所以 `skynet_message` 是一个必不可少的一环


# 结构

`skynet_message` 并非是一个指针，而是一种数据承载，它被设计成一个很紧凑并且很小的结构,使得它会被分配到`stack`上，减轻了gc负担

```go
type skynet_message struct{
    _ [0]func()  // don't copy

    skynet_event byte

    session uint32

    typ uint32

    source pid

    argument unsafe.Pointer

}
```


# 服务的消息队列

也存在两个版本，一个是基于go channel，另外一个基于无锁缓冲队列，后续有时间会单独解释。

唯一的区别是 第二种方式需要手动控制调度调度规则，对服务参数的配置有更高的要求，正确的配置,内存以及性能会比 `go channel`的方式略高


# 消息的接受和发送

+ 发送

用户不需要构建这个结构体，仅仅需要指定 `destination` 以及需要发送的数据，而且 `skynet` 消息投递被设计成不允许发送 `nil` 因为这是无任何意义的，相反它消耗服务投递的性能，
如果确实有这种需求，可以发送 `struct{}{}`


+ 接收

用户能收到的数据不全是结构体的字段，关键性参数只有三个，`session`,`typ`,以及 `argument`,
`session` 主要的作用是用以区分这条消息是否是同步请求，
`typ` 仅仅是一个消息类别的区分，类似于消息号
`argument` 才是真实的数据，特别的，在`lua`中这个值是会被解构。



# 异步消息

异步消息通过 `skynet.send`的方式进行投递，它只在乎这个消息有没有正确到达到对点服务，而不关心是否能被对点服务正确处理，返回一个 `error`

# 同步消息

同步消息通过 `skynet.call`的方式进行投递，它会阻塞当前协程（goroutien 或者是 coroutine），它也返回一个错误，能解除此次阻塞只有两个条件，对点服务`skynet.reply` 或者达到了指定超时时间，
所以特别在远程通讯的时候要考虑到 i/o 的延时


# dead letter

这个很好理解，同`erlang` 主要是确保数据的一致性，保证重要的数据不会因为某个服务的意外退出而丢失了这些消息.

当然是否开启也是可配置的.
