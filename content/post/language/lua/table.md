---
title: lua's table
date: 2019-03-18
tags: ["table"]
categories: ["lua"]
description: lua是一个好东西
toc: true
draft: true
top: true
---


# 元表(`metatable`)

``` lua
--设置 t0 的元表为 t1，若t0已经设置过，__metatable键存在则会失败
setmetatable(t0,t1)

--获取 t0 的元表，存在返回一个table，否则返回nil
getmetatable(t0)
```
>`rawget` 、 `rawset` 将不会触发任何元表操作。

<!--more-->
## 元方法
* `__index` 索引元表时
    ``` lua
    --若__index指向一个table
    setmetatable(t0,{__index = t1})
    --同样的效果
    setmetatable(t0,t1)
    t1.__index = t1
    --访问t0不存在的元素会重新定向到t1中去搜索
    t0.a --1

    --若__index指向一个function,会将 t0 与 a 传入方法中
    setmetatable(t0,{__index = function(t,key) end})
    ```

* `__newindex` 对元表更新时
    ``` lua
    --若__newindex指向一个table
    setmetatable(t0,{__newindex = t1})
    --同样的效果
    setmetatable(t0,t1)
    t1.__newindex = t1
    --设置t0中不存在的元素，会影响到t1
    t0.a = 20
    t1.a -- 20
    --若__newindex指向一个function,会将 t0 与 a 以及新的值传入方法中
    setmetatable(t0,{__newindex = function(t,key,value) end})
    ```

* `__metatable` 元表属性
    ``` lua
    t0.__metatable = t2
    ```

* `__tostring` 元表输出
    ``` lua
    --__tostring只能指向含一个参数和字符串返回的函数，x是table自身
    t1.__tostring = function(x)
        return "t1" 
    end
    setmetatable(t0,t1)
    print(t0) -- t1
    ```

* `__call` 将元表以函数的形式调用
    ``` lua
    setmetatable(t0,{__call = function(t,...)
    -- t 是 t0
    -- ...是args，一个可变参数
    end})
    t0(args)
    ```

* 算数元方法: `__add` (加),`__sub` (减),`__mul` (乘),`__div` (除),`__unm` (相反),`__mod` (取模),`__pow` (幂乘),`__concant` (连接),`__lt` (小于),`__le` (小于等于),`__eq` (等于)
    ``` lua
    --参数时 table0，table1
    local function add(t1,t2)
        local sum = 0
        sum = t1.c+t2.a
        return sum
    end
    -- 同时指向一个方法
    setmetatable(t0,{__add = add})

    setmetatable(t1,{__add = add})

    print(t0+t1) -- 11
    -- 其他的类似
    ```
---
# 通过 `metatable` 构建 `class`

## oop

```lua

local any = {}

any.__index = function(t,k)
    return rawget(t,k)
end

any.__newindex = function(t,k,v)
    rawset(t,k,v)
end

function any.ctor(...) 
    local t = {}

    setmetatable(t,any)

    return t
end

```

## 元方法
``` lua
--预定 t0 t1
local t0 = {c = 10}
local t1 = {a = 1,b = 2}
```
* `__index` 索引元表时
    ``` lua
    --若__index指向一个table
    setmetatable(t0,{__index = t1})
    --同样的效果
    setmetatable(t0,t1)
    t1.__index = t1
    --访问t0不存在的元素会重新定向到t1中去搜索
    t0.a --1

    --若__index指向一个function,会将 t0 与 a 传入方法中
    setmetatable(t0,{__index = function(t,key) end})
    ```

* `__newindex` 对元表更新时
    ``` lua
    --若__newindex指向一个table
    setmetatable(t0,{__newindex = t1})
    --同样的效果
    setmetatable(t0,t1)
    t1.__newindex = t1
    --设置t0中不存在的元素，会影响到t1
    t0.a = 20
    t1.a -- 20
    --若__newindex指向一个function,会将 t0 与 a 以及新的值传入方法中
    setmetatable(t0,{__newindex = function(t,key,value) end})
    ```

* `__metatable` 元表属性
    ``` lua
    t0.__metatable = t2
    ```

* `__tostring` 元表输出
    ``` lua
    --__tostring只能指向含一个参数和字符串返回的函数，x是table自身
    t1.__tostring = function(x)
        return "t1" 
    end
    setmetatable(t0,t1)
    print(t0) -- t1
    ```

* `__call` 将元表以函数的形式调用
    ``` lua
    setmetatable(t0,{__call = function(t,...)
    -- t 是 t0
    -- ...是args，一个可变参数
    end})
    t0(args)
    ```

* 算数元方法: `__add` (加),`__sub` (减),`__mul` (乘),`__div` (除),`__unm` (相反),`__mod` (取模),`__pow` (幂乘),`__concant` (连接),`__lt` (小于),`__le` (小于等于),`__eq` (等于)
    ``` lua
    --参数时 table0，table1
    local function add(t1,t2)
        local sum = 0
        sum = t1.c+t2.a
        return sum
    end
    -- 同时指向一个方法
    setmetatable(t0,{__add = add})

    setmetatable(t1,{__add = add})

    print(t0+t1) -- 11
    -- 其他类似
    ```



## 方法重写、继承  
本质是不去索引 `__index` 元方法，重写需要命名为自身类的同名方法，继承直接通过实例调用即可。


## 优化

+ 如果是`hash table` 使用直接赋值的方式，比 `table.insert(tab,val)` 和 `table.insert(tab,n,val)` 高,原因是table的底层结构的问题

+ 多次访问的字段，使用局部变量保存

+ 减少函数调用，在底层是 `Function Proto` 函数原型， 所以并不会存在内联或者死码消除的优化

+ 字符串相加 `..` 这个看情况吧，本质上所有语言都有这个毛病，大字符串用 `table` 模拟 `string buffer` 然后用 `concat` 得到

+ `#` 这个只能用于数组`table`

+ 3R原则 所有语言通用，`Reducing` 避免频繁创建不重要的对象 `Reusing` 复用旧对象 `Recying` 这个跟语言相关（lua是一个增量运行的的机制，每次gc一小部分）频繁的垃圾回收会降低程序的性能，通过`collectgarbage` 控制

+ 尽量使用宿主语言封装api