# mvcc



# MVCC 

> multi-version concurent control 多版本控制系统，一般用于数据库的并发访问

MVCC在MySQL InnoDB中的实现主要是为了提高数据库的并发性能，用更好的方式去处理读-写冲突，做到即使有读写冲突时，也能做到不加锁，非阻塞并发读。


# 当前读

像 `select lock in share mode,select for update ,update,insert,delete` 都算当前读，即读取的记录都是数据库中最新的版本，读取是还要保证其他并发事务不能修改当前记录，所以会对读数据加锁


# 快照读

不加锁的`select`就是快照读，但前提是隔离基本不是串行级别，否则会退化成当前读


# 原理

通过隐藏列

