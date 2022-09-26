# skynet编码协议



# 前言

其实在`cobweb`之初就设计了一种编码协议(bbuf)，用于 `RPC Server`,但因为公司项目长期需要维护以及开发（两款线上，一款开发中），所以一直未对此库进行维护，
而后期在研发 `skynet` 的时候，发现需要与多种语言交互，显然 `json`,`xml` 不是一个很好的选择，所以此库被重新提出来进行维护。


# 词法解析器

    ## 因为需要和强类型和弱类型进行转换，词法解析器和描述文件需要一个抽象共用类型加以识别

    ## Lua5.1 明显是没有整数类型，所以需要独立出 浮点和整形

    ## Lua 纯数组table和hash table 的编码方式也是不同的


# 代码生成器
    
    强类型和弱类型的识别是有很大区别，所以我对`Lua` 这边进行了直接解析，简单来说是直接通过 `Lexer` 生成此消息结构的元信息.(这点是完全区别于云风大神的`skynet`的)，
    强类型语言为了减少反射，我们需要通过文件描述来提供其成员或字段的类型以及位置而非通过反射，这个在编译期间就可以确定了。


# 编码

    ## 减少内存分配
         为了减少i/o和内存压力，最简单的办法是让一个字节能包含更多的消息， 如一个32bit的整形，它真的需要4byte的字节空间吗？,其二不同的分配大小影响执行速度，（如32byte和64kb 是存在明显区别），
         所以需要动态计算分配尺寸。

    ## 反射 
        显然反射是所有带运行时语言的一个痛点，而通过 `unsafe.Pointer` 能明显提高执行速率，所以 `spb` 采用了大量非安全指针，

        当然在 `bbuf` 设计之初是没有考虑嵌套消息的，原因在于不一定需要通过嵌套消息，因为这会加大分析负担，而实际情况恰恰相反，消息嵌套是实际业务中必不可少的一部分

        但go语言的接口本质上是两个指针（其一指向类型系统，其二指向该类型的具体方法），所以要支持消息嵌套，我们需要一点点反射来支持。

    ## API
        我在这里提供两个主要语言的api （`go` `lua`）

        ## Lua
            ```lua
                local spb = require("skyent.spb")
                local err = spb.load("file path or dir path")  -- 注意 此函数执行结果在当前节点是共享的，所以只需要加载一次，并返回一个错误（string）
                if err~=nil then
                    // do something
                end

                local data ,err = spb.marshal(string,table)   -- 此时返回的data是 `userdata`,不要尝试访问它，但你可以通过 `skynet.free` 来释放它.也可以通过`skynet.send,skynet.call` 来发送到其他服务.

                local err = spb.unmarshal(string,data)  -- 仅返回一个错误，并将具体数据映射到传入的 `table` 中
            ```

        # go
            ```go

                spb.Marshal(msg,[n])   // 可选参数n 是为了减少 sizeof 的时间，如果你确定消息内容是一致的 那么这个值你可以传入，否则使用`-1`来让它自动计算

                spb.Unmarshal([]byte,msg)

            ```

    ## spb文件结构
        ```
            package gen   // 包名，主要是为了在go和c#中区分同名协议
            // 注释哦

            enum Foo {
                A : 0
                B : 1
                C : 2
            }

            message empty {}  // 一个空消息

            message PhoneNumber{  
                string number : 0 

                integer type : 1  
            }

            message Person{
                string name : 0
                integer id : 1
                string email: 2

                *PhoneNumber phones : 3  // 嵌套类型的数组

                PhoneNumber phone : 4  // 嵌套类型
            }


            message AddressBook {
                *Person person : 0
            }

        ```


