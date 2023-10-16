---
title: Docker
date: 2019-03-12
tags: ["docker"]
categories: ["cloud native"]
description: Docker是一个好东西
img: https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=3775172144,3501685571&fm=58&bpow=500&bpoh=416
toc: true
draft: false
---

# 什么是docker

Docker 是一个开源的容器引擎，可以轻松的为任何应用创建一个轻量级的、可移植的、自给自足的容器。开发者和系统管理员在笔记本上编译测试通过的容器可以批量地在生产环境中部署，包括 VMs（虚拟机）、bare metal、OpenStack 集群、云端、数据中心和其他的基础应用平台。容器是完全使用沙箱机制，相互之间不会有任何接口。

# 有什么优势

+ 轻量，在一台机器上运行的多个Docker容器可以共享这台机器的操作系统内核；它们能够迅速启动，只需占用很少的计算和内存资源。镜像是通过文件系统层进行构造的，并共享一些公共文件。这样就能尽量降低磁盘用量，并能更快地下载镜像。

+ 标准，Docker 容器基于开放式标准，能够在所有主流Linux版本、Microsoft Windows以及包括VM、裸机服务器和云在内的任何基础设施上运行。

+ 安全，Docker 赋予应用的隔离性不仅限于彼此隔离，还独立于底层的基础设施。Docker默认提供最强的隔离，因此应用出现问题，也只是单个容器的问题，而不会波及到整台机器。

+ 一次发布，到处使用


# Docker和虚拟机

>容器和虚拟机具有相似的资源隔离和分配优势，但功能有所不同，因为容器虚拟化的是操作系统，而不是硬件，因此容器更容易移植，效率也更高。 

传统虚拟机技术是虚拟出一套硬件后，在其上运行一个完整操作系统，在该系统上再运行所需应用进程；而容器内的应用进程直接运行于宿主的内核，容器内没有自己的内核，而且也没有进行硬件虚拟。因此容器要比传统虚拟机更为轻便。


特性|容器|虚拟机
:-:|:-:|:-:
启动|秒级|分钟级
硬盘|MB|GB
性能|接近原生|弱于原生
支持量|单机上千|单机几十左右

+ 容器是一个应用层抽象，用于将代码和依赖资源打包在一起。 多个容器可以在同一台机器上运行，共享操作系统内核，但各自作为独立的进程在用户空间中运行 。与虚拟机相比， 容器占用的空间较少（容器镜像大小通常只有几十兆），瞬间就能完成启动。

+ 虚拟机（VM）是一个物理硬件层抽象，用于将一台服务器变成多台服务器。 管理程序允许多个VM在一台机器上运行。每个VM都包含一整套操作系统、一个或多个应用、必要的二进制文件和库资源，因此占用大量空间。而且VM启动也十分缓慢 。

>虚拟机更擅长于彻底隔离整个运行环境。例如，云服务提供商通常采用虚拟机技术隔离不同的用户。而 Docker 通常用于隔离不同的应用 ，例如前端，后端以及数据库。

# Docker基本组成

+ 镜像 （Image）

+ 容器（Container）

+ 仓库（Repository）

## 镜像（Image）—— 一个特殊的文件系统

>操作系统分为内核和用户空间。对于Linux而言，内核启动后，会挂载root文件系统为其提供用户空间支持。而Docker镜像（Image），就相当于是一个root文件系统。Docker镜像是一个特殊的文件系统，除了提供容器运行时所需的程序、库、资源、配置等文件外，还包含了一些为运行时准备的一些配置参数（如匿名卷、环境变量、用户等）。 镜像不包含任何动态数据，其内容在构建之后也不会被改变。Docker设计时，就充分利用Union FS的技术，将其设计为分层存储的架构。 镜像实际是由多层文件系统联合组成。镜像构建时，会一层层构建，前一层是后一层的基础。每一层构建完就不会再发生改变，后一层上的任何改变只发生在自己这一层。比如，删除前一层文件的操作，实际不是真的删除前一层的文件，而是仅在当前层标记为该文件已删除。在最终容器运行的时候，虽然不会看到这个文件，但是实际上该文件会一直跟随镜像。因此，在构建镜像的时候，需要额外小心，每一层尽量只包含该层需要添加的东西，任何额外的东西应该在该层构建结束前清理掉。分层存储的特征还使得镜像的复用、定制变的更为容易。甚至可以用之前构建好的镜像作为基础层，然后进一步添加新的层，以定制自己所需的内容，构建新的镜像。

## 容器（Container）—— 镜像运行时的实体

>镜像（Image）和容器（Container）的关系，就像是面向对象程序设计中的类和实例一样，镜像是静态的定义，容器是镜像运行时的实体。容器可以被创建、启动、停止、删除、暂停等 。容器的实质是进程，但与直接在宿主执行的进程不同，容器进程运行于属于自己的独立的命名空间。前面讲过镜像使用的是分层存储，容器也是如此。容器存储层的生存周期和容器一样，容器消亡时，容器存储层也随之消亡。因此，任何保存于容器存储层的信息都会随容器删除而丢失。按照Docker最佳实践的要求，容器不应该向其存储层内写入任何数据 ，容器存储层要保持无状态化。所有的文件写入操作，都应该使用数据卷（Volume）、或者绑定宿主目录，在这些位置的读写会跳过容器存储层，直接对宿主（或网络存储）发生读写，其性能和稳定性更高。数据卷的生存周期独立于容器，容器消亡，数据卷不会消亡。因此， 使用数据卷后，容器可以随意删除、重新run，数据却不会丢失。

## 仓库（Repository）—— 集中存放镜像文件的地方

>镜像构建完成后，可以很容易的在当前宿主上运行，但是， 如果需要在其它服务器上使用这个镜像，我们就需要一个集中的存储、分发镜像的服务，Docker Registry就是这样的服务。一个Docker Registry中可以包含多个仓库（Repository）；每个仓库可以包含多个标签（Tag）；每个标签对应一个镜像。所以说：镜像仓库是Docker用来集中存放镜像文件的地方类似于我们之前常用的代码仓库。通常，一个仓库会包含同一个软件不同版本的镜像，而标签就常用于对应该软件的各个版本 。我们可以通过<仓库名>:<标签>的格式来指定具体是这个软件哪个版本的镜像。如果不给出标签，将以latest作为默认标签。

## Docker Registry公开服务和私有Docker Registry

>Docker Registry公开服务是开放给用户使用、允许用户管理镜像的Registry服务。一般这类公开服务允许用户免费上传、下载公开的镜像，并可能提供收费服务供用户管理私有镜像。最常使用的Registry公开服务是官方的Docker Hub ，这也是默认的Registry，并拥有大量的高质量的官方镜像，网址为：hub.docker.com/ 。在国内访问Docker Hub可能会比较慢国内也有一些云服务商提供类似于Docker Hub的公开服务。除了使用公开服务外，用户还可以在本地搭建私有Docker Registry 。Docker官方提供了Docker Registry镜像，可以直接使用做为私有Registry服务。开源的Docker Registry镜像只提供了Docker Registry API的服务端实现，足以支持Docker命令，不影响使用。但不包含图形界面，以及镜像维护、用户管理、访问控制等高级功能。

# Image

## 查看、拉取、删除

+ 搜索镜像

	`docker search name[:tag]`
	
+ 拉取镜像,若不指定tag则默认拉取`latest`

	`docker pull name[:tag]`


+ 查看本地所有镜像

	`docker images`

+ 删除镜像，可以多个删除
	
	`docker rmi [option] image ... `

	+ `-f` 强制删除


## 制作、推送

+ 在指定路径中找到 [Dockerfile](/post/Dockerfile) 并构建Image, 后面是路径，但路径中必须存在 `Dockerfile`

	`docker build -t [:namespace]/name:tag Path`


+ 给镜像赋予新的标签, `namespace` 必须为 `dockerid`，除非另外购买。

	`docker tag oldname:oldtag  namespace/newname:newtag`

+ 将镜像上传至 docker 仓库 DockerHub 上,`namespace` 必须是用户名,也可以上传至 `Gitlab`
 	
	 `docker push namespace/name:tag`

	 `docker`

+ 提交修改的镜像

	`docker commit [-a] [-m] CONTAINER [REPOSITORY[:TAG]]`
	+ `-a` 指明提交者

	+ `-m` 提交信息

	在原有镜像的基础上，再叠加上容器的存储层，并构成新的镜像。以后我们运行这个新镜像的时候，就会拥有原有容器最后的文件变化。
	此方式更新的镜像有依赖通过 `docker save -o dst [REPOSITORY[:TAG]]`存盘,删除所有镜像,再通过 `docker load -i path` 加载新镜像。


# Container

## 查看容器

`docker ps [-a|-s]`

+ `-a` 查看所有容器。

+ `-s` 查看已启动的容器。

## 产看容器进程

`docker top containerID`

## 移除容器

> 可以多个同时删除

`docker rm container ...  [option]`

+ `-f` : 强制删除容器。

+ `-v` : 若删除容器则数据卷也删除。

## 停止容器

> 可以同时停止多个

`docker stop container ...`

## 启动容器

`docker run [:--name] [:-e] [:-v] [:-h] [:--net] [:-p prot0:prot1] [:-d|-i] [:-t] [:--rm] [:--restart] [:--privileged=false] [:--ip] [:--network=] name:tag [:shell]`

+ `run` 命令将会启动 `dockerfile` 中定义的 `CMD` 或 `ENTRYPOINT` 指令。

+ `--name=xxx` 指定容器运行时的名称，可不选，默认为随机字符。

+ `-p Host0:Host1` 表示本地 Host0 映射容器 Host1 端口,若为 `-P` 则随机映射49000 ~ 49900 端口。

+ `-d`：分离模式: 在后台运行。

+ `-h`：指定主机域名。如 `-h domyson.cn`。

+ `-e`：为 `dockerfile` 中的 `ENV` 的参数变量,设置环境变量，或者覆盖已存在的环境变量 `-e TZ="Asia/Shanghai"` 设置时区为上海。

+ `-u`：~~指定执行用户，一般为 `root`。~~

+ `--rm`：停止容器就移除。

+ `-it`: 以交互模式运行容器 (不同于 `-d` : 以分离模式运行容器),这意味着交互回话 session 结束时,容器就会停止运行，与 `-d` 互斥。

+ `-v` : 容器内创建一个数据卷。多次重复使用 -v 标记可以创建多个数据卷，也可以挂载一个主机目录作为数据卷 path0:path1(其中path0是主机目录，path1是容器目录)。

+ `--link container` : ~~连接到其他容器。~~ 这个方法以后将被弃用，推荐使用 `--network`

+ `--network NETWORK`：指定连接到的网络。

+ `--ip`：指定容器的ip。

+ `--restart`：`no、on-failure:n、always` 设置容器自动重启模式，若容器已经启动，可以通过 `docker update --restart args` 来设置参数。

+ `--privileged`：真正给予 `Container 中 root 用户` root权限，否则 `root` 只是一个普通用户。

+ `shell`：指定交互的方式，一般为bash `bash -c "cmd string"`，这条命令将由启动容器执行。


## 查看容器日志

`docker logs [opt] CONTAINER`

+ `-f` : 跟踪日志输出

+ `--since` :显示某个开始时间的所有日志

+ `-t` : 显示时间戳

+ `--tail N` :仅列出最新N条容器日志

## 进入指定容器

`docker exec [opt] CONTAINER shell [:args]`

+ `-d` ：分离模式: 在后台运行

+ `-it`：以交互模式运行容器 (不同于 -d : 以分离模式运行容器),这意味着交互回话 session 结束时,容器就会停止运行。与 `-d` 互斥

+ `-u`：指定运行用户,一般设置为 root 

+ 进入容器内部之后，通过 `exit` 退出


## 容器通讯方式

[See DockerNetwork](/2020/01/Docker-Network/)



# 镜像体积优化

> `Docker` 由多个 `Layers` 组成（上限是127层）。而 [Dockerfile](/2019/03/Dockerfile) 每一条指令都会创建一层 `Layers`。

## 优化基础镜像

+ 使用 `Alpine` 基础镜像

	> Alpine是一个高度精简又包含了基本工具的轻量级Linux发行版，基础镜像仅 `4.41MB`

+ 使用 `scratch` 基础镜像

	> scratch是一个空镜像，只能用于构建其他镜像

+ 使用 `busybox` 基础镜像

	> 如果希望镜像里可以包含一些常用的Linux工具，busybox镜像是个不错选择，镜像本身只有1.16M，非常便于构建小镜像。

## 串联 `Dockerfile` 指令

> 通过  `&&` 和 `\` 将多个 `Run` 命令合并成一个

## 多段构建

待完善

##


# Docker数据卷

+ 数据卷可以在容器之间共享和重用
+ 对数据卷的修改会立马生效
+ 对数据卷的更新，不会影响镜像
+ 数据卷默认会一直存在，即使容器被删除

## 创建数据卷
```
在 run 命令中 -v /data 标记来创建一个数据卷并挂载到容器里。在一次 run 中多次使用可以挂载多个数据卷。(创建一个容器，并加载一个数据卷到容器的 /data 目录)

也可以在 Dockerfile 中使用  VOLUME  来添加一个或者多个新的卷到由该镜像创建的任意容器。
```


## 删除数据卷
```
数据卷是被设计用来持久化数据的，它的生命周期独立于容器，Docker不会在容器被删除后自动删除数据卷，并且也不存在垃圾回收这样的机制来处理没有任何容器引用的数据卷。如果需要在删除容器的同时移除数据卷。可以在删除容器的时候使用  docker rm -v  这个命令。无主的数据卷可能会占据很多空间，要清理会很麻烦。
```

## 挂载一个主机目录作为数据卷

```
docker run -d -P --name web -v /src/webapp:/opt/webapp[:权限]

上面的命令加载主机的  /src/webapp  目录到容器的  /opt/webapp  目录，默认权限是读写，也可以指定为只读(ro)

--volumes-from 在run的时候指定数据卷容器
```

+ 查看数据卷的信息

	`docker inspect contianerID`


+ 查看所有数据卷

 	`docker volume ls`

+ 清除所有无主数据卷

	`docker volume prune`



# Docker权限验证

1. 版本

	`docker version` 

2. 登陆

	`docker login`

3. 登出

	`docker logout`


# Docker远程访问


# Docker-Compose

> `Docker-Compose` （docker编排）是 docker 提供的一个命令行工具，用来定义和运行由多个容器组成的应用。可以通过 docker-compose.yml 文件声明式的定义应用程序的各个服务，并由单个命令完成应用的创建和启动。

> [官方文档](https://docs.docker.com/compose/)


`Docker-Compose`将所管理的容器分为三层，分别是工程（project），服务（service）以及容器（container）。Docker-Compose运行目录下的所有文件（docker-compose.yml，extends文件或环境变量文件等）组成一个工程，若无特殊指定工程名即为当前目录名。一个工程当中可包含多个服务，每个服务中定义了容器运行的镜像，参数，依赖。一个服务当中可包括多个容器实例，Docker-Compose并没有解决负载均衡的问题，因此需要借助其它工具实现服务发现及负载均衡。

<!--more-->

# docker-compose 命令

## docker-compse up [opthions] [--scale SERVICE=NUM] [SERVICE...]

> 容器启动命令

+ `-d`：在后台运行

+ `–no-color` 不使用颜色来区分不同的服务的控制输出

+ `–no-deps` 不启动服务所链接的容器

+ `–force-recreate` 强制重新创建容器，不能与`–no-recreate`同时使用

+ `–no-recreate` 如果容器已经存在，则不重新创建，不能与`–force-recreate`同时使用

+ `–no-build` 不自动构建缺失的服务镜像

+ `–build`：在启动容器前构建服务镜像，或rebuild

+ `–abort-on-container-exit`：停止所有容器，如果任何一个容器被停止，不能与 `-d` 同时使用

+ `–scale SERVICE=NUM ...` 设置服务运行容器的个数，将覆盖在compose中通过scale指定的参数

## docker-compose ps [SERVICE...]

> 查看 `docker-compose` 中列出的容器

## docker-compose [start|stop|restart]

> [开始|停止|重启]项目中运行的容器

# docker-compose 文件结构

>Docker-Compose标准模板文件应该包含version、services、networks 三大部分，最关键的是services和networks两个部分。

```yaml
version: "3.5"                  #docker-compose 版本,不同的版本配置有所不同
service:
  nats:                         #标识,如果设置了网络，这个也是他在网络中的别名，也可以指定alias
    image: nats:latest          #如果本地不存在就会在dockerhub上拉取
    container_name: "nats0"     #运行时的容器名
    ports:                      #端口与宿主机映射规则
      - "4222:4222"
      - "6222:6222"
      - "8222:8222"
    expose:                     #暴露容器端口，仅仅是声明，不会起实际作用，参考 Dockerfile
      - "4222"
      - "8222"
      - "6222"
    networks:                   #链接的网络，不存在会自动创建，必须在services同级的networks中指定
      - net1                    #指定连接的网络名
      - net2                    


  gate:
    image: gateway
    build: "./gateway"          #如果此镜像是自定义镜像，需要指定dockerfile文件的目录，将不会拉取远程镜像
    container_name: "gateway"
    command: sh run.sh          #覆盖容器的默认执行命令
    depends_on:                 #指定依赖的启动项，即先启动 nats 再启动此镜像
      - nats
      - login
    ports:
      - "5433:5433"
    expose:
      - "5433"
    networks:
      net1:
        ipv4_address: 172.18.0.31 #指定容器的固定ipv4地址

  login:
    image: login
    build: "./login"
    container_name: "login"
    ports:
      - "5434:5434"
    expose:
      - 5433
    networks:
      - net1
  db:
    image: db
    build: "./db"
    container_name: "db"
    networks:
      - net1
    volumes:
      - /var/etc/:/var/etc/     #容器卷映射


networks:
  net1:
    name: xNet                  #虚拟网卡名 version >=3.5
    driver: bridge              #支持三种模式 host bridge(默认) none
  net2:
    name: yNet
    driver: host
```


# dockerfile

# Dockerfile

> `Dockerfile` 是一个包含用于组合映像的命令的文本文档。可以使用在命令行中调用任何命令。 Docker通过读取Dockerfile中的指令自动生成映像。`docker build` 命令用于从 `Dockerfile`构建映像。命令中使用 `-f` 标志指向文件系统中任何位置的 `Dockerfile` 文件。

## FROM

> 指定基础镜像
    
`FROM <image>:<tag>`

```dockerfile
FROM node:10.14.2
# tag为可选项，如果没有指定，默认为latest
# 指定基础，FROM必须作为第一个指令，若镜像不存在则会下载，如果不以任何镜像为基础，则写法为：FROM scratch，意味着接下来的指令作为第一层镜像的开始。
```

## MAINTAINER 

> 镜像作者 已过时，用  [Label](#LABEL) 代替

~~`MAINTAINER <name>`~~
   
```dockerfile
#MAINTAINER Treasure
LABEL maintainer=Treasure
```

## ADD、COPY

> ADD、COPY目标文件夹若不存在会自动创建。ADD指令包含类似tar的解压功能，而COPY只单纯复制文件，而且路径不能是url。ADD和COPY只能复制文件，若碰到文件夹只会复制其中的文件。`dst` 只能是目标容器的绝对位置。 所有拷贝到容器中的文件和文件夹权限为 `0755`，uid和gid为0；如果是一个目录，那么会将该目录下的所 有文件拷贝到目录下，不包括目录；如果是文件且中不使用斜杠结束，则会将视为文件，则内容会写入；如果是文件且中使用斜杠结束，则会文件拷贝到目录下。 

`ADD src ... dst` 

`COPY src ... dst`

```dockerfile
ADD ./* /data

COPY ./ /data
```

## WORKDIR

> 将会设置 RUN、CMD、ENTRYPOINT指定的工作目录,相当于切换目录至path

`WORKDIR path`

```dockerfile
WORKDIR /app    #工作目录为 /app

WORKDIR gateway #工作目录为 /app/gateway
```

## USER

> 指定运行容器的用户

```dockerfile
USER root
```

## LABEL

>为镜像指定标签，LABEL会继承基础镜像中的LABEL，如遇到key相同，则会被覆盖。

```dockerfile
LABEL <key>=<value> <key>=<value> ...

LABEL <key>=<value> \
    <key>=<value>
```

## ENV

> ENV指令用来定义镜像的环境变量，在Dockerfile中这些设置的环境变量也会影响到RUN指令，当运行生成的镜像时这些环境变量依然有效，如果需要在运行时更改这些环境变量可以在运行docker run时添加–e <key>=<value>参数来修改。可以通过 docker inspect 查看环境变量。其他命令通过 $EVNNAME 来引用,最好不要定义那些可能和系统预定义的环境变量冲突的名字，否则可能会产生意想不到的结果。

``` dockerfile
ENV HOST=0.0.0.0 PORT=8000 #可以设置多个,但`=`两侧不允许有空格

ENV A1=Treasure \
    A2=DoMySon

WORKDIR ${foo} #引用ENV设置的变量
```

## EXPOSE

> 功能为暴漏容器运行时的监听端口给外部（只允许能被连接的服务访问）,但是EXPOSE并不会使容器访问主机的端口,如果想使得容器与主机的端口有映射关系，必须在容器启动的时候加上 `-p` 参数

``` dockerfile
EXPOSE 8000 3306 

EXPOSE 80

EXPOSE 5433/tcp 5434/udp
```


## VOLUME

> 可实现挂载功能，可以将本地文件夹或者其他容器种得文件夹挂在到这个容器中，若目标文件夹或文件不存在则创建

```dockerfile
VOLUME ["path1","path2"] #主机上的挂点是随即生成的 

VOLUME /var/log /var/db #挂载多个
```


## RUN

> 在容器中构建时执行的命令，RUN指令创建的中间镜像会被缓存，并会在下次构建中使用。如果不想使用这些缓存镜像，可以在构建时指定--no-cache参数：`docker build --no-cache`

```dockerfile
RUN npm install                         #使用 shell 执行

RUN ["executable","param1","param2"]    #使用可执行程序执行 
```

## CMD

> 功能为容器启动时要运行的命令CMD指令中指定的命令会在镜像运行时执行，在Dockerfile中只能存在一个，如果使用了多个CMD指令，则只有最后一个CMD指令有效。当出现ENTRYPOINT指令时，CMD中定义的内容会作为ENTRYPOINT指令的默认参数，也就是说可以使用CMD指令给ENTRYPOINT传递参数。`RUN`和`CMD`都是执行命令，他们的差异在于`RUN`中定义的命令会在执行`docker build`命令创建镜像时执行，而`CMD`会在`docker run`时执行。

```dockerfile
CMD npm install                         #使用 shell 执行

CMD ["executable","param1","param2"]    #使用可执行程序执行 
```

## ENTRYPOINT

> 功能是启动时的默认命令，与 `CMD` 相似，如果有多条则最后一条生效。但ENTRYPOINT不会被command覆盖，而 CMD 则会被覆盖。

```dockerfile
ENTRYPOINT ["exec","param1","param2"]

ENTRYPOINT command
```

## USER

> 设置启动容器的用户，可以是用户名或UID,如果设置了容器以daemon用户去运行，那么 RUN, CMD 和 ENTRYPOINT 都会以这个用户去运行

```dockerfile
USER daemo

USER UID
```


## ARG

> 设置变量命令，ARG命令定义了一个变量，在 docker build 创建镜像的时候，使用 --build-arg <varname>=<value>来指定参数，如果用户在build镜像时指定了一个参数没有定义在Dockerfile中，那么将有一个 Warning

```dockerfile
ARG <name>[=<default_value>]

ARG user1=10 #默认值变量

ARG build #不带默认值变量
```

## ONBUILD

> 这是一个特殊的指令，它后面跟的是其它指令，比如 RUN , COPY等，而这些指令， 在当前镜像构建时并不会被执行。只有当以当前镜像为基础镜像，去构建下一级镜像的时候才会被执行。



# docker network


# Docker Network

> `Docker` 在安装时候，默认创建三个网络 `bridge（默认）`,`none`,`host`。

> `docker network create --driver [bridge|host|none|container] networkname`

+ `bridge`：默认模式，容器使用独立 network Namespace，并连接到`docker0`虚拟网卡（默认模式）。通过该网桥以及Iptables nat表配置与宿主机通信，此模式会为每一个容器分配Network Namespace、设置IP等，并将一个主机上的容器连接到同一个网桥 `docker0` 中。

+ `host`：与宿主机共享网络，此时容器没有使用网络的namespace，`-p` 将不会起任何作用。

+ `container`：新创建的容器和已经存在的一个容器共享一个Network Namespace,新创建的容器不会创建自己的网卡，配置自己的IP，而是和一个指定的容器共享IP、端口范围等。同样，两个容器除了网络方面，其他的如文件系统、进程列表等还是隔离的。两个容器的进程可以通过lo网卡设备通信。

+ `none`：该模式将容器放置在它自己的网络栈中，但是并不进行任何配置。实际上，该模式关闭了容器的网络功能，在以下两种情况下是有用的：容器并不需要网络（例如只需要写磁盘卷的批处理任务）。

+ `container`：与指定的容器共享网络，如果有的话。


# 容器连接

1. 通过 `docker network ls` 查看网络信息。

2. 运行容器时通过 `--network=[networkname]` 指定连接的网络（未测试是否可以同时连接多个）。若不指定则默认连接到 `bridge` 网络。 也可以同过 `--net=[networkmode]` 指定网络的模式。同时通过 ``。

    + --net=host
    
    + --net=none

    + --net=bridge

    + --net=container




# Docket 跨主机通讯

## 自己yy

两个宿主机的容器映射到宿主机的端口，然后通讯。

## overlay



{{< adsense-footer>}}
