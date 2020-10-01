# 快速参考
- **维护者**：
[Enmotech OpenSource Team](https://github.com/enmotech)
- **哪里可以获取帮助**：
[墨天轮-openGauss](https://www.modb.pro/openGauss)

# 支持的tags和 `Dockerfile`链接
-	[`1.0.0`,`1.0.1`, `latest`](https://github.com/enmotech/enmotech-docker-opengauss/blob/master/1.0.1/dockerfile_arm)


# 关于openGauss
openGauss是一款开源关系型数据库管理系统，采用木兰宽松许可证v2发行。openGauss内核早期源自PostgreSQL，深度融合华为在数据库领域多年的经验，结合企业级场景需求，持续构建竞争力特性。同时openGauss也是一个开源、免费的数据库平台，鼓励社区贡献、合作。

openGauss社区官方网站：[https://opengauss.org/](https://opengauss.org/)

![logo](https://github.com/enmotech/enmotech-docker-opengauss/blob/master/origin-opengauss-text.png)

# 云和恩墨openGuass镜像的特点
* 云和恩墨会最紧密跟踪openGauss的源码变化，第一时间发布镜像的新版本。
* 云和恩墨的云端数据库，虚拟机数据库以及容器版本数据库均会使用同样的初始化最佳实践配置，这样当您在应对各种不同需求时会有几乎相同的体验。
* 云和恩墨会持续发布不同CPU架构（x86或者ARM）之上，不同操作系统的各种镜像

**目前已经支持x86-64和ARM64两种架构，会根据您获取镜像时运行的机器架构自动判断。**
- x86-64架构的openGuass运行在[CentOS7.6操作系统](https://www.centos.org/)中
- ARM64架构的openGauss运行在[openEuler 20.03 LTS操作系统](https://openeuler.org/zh/)中

# 如何使用本镜像

## 启动openGuass实例

```console
$ docker run --name opengauss --privileged=true -d -e GS_PASSWORD=Enmo@123 enmotech/opengauss:latest
```

## 环境变量
为了更灵活的使用openGuass镜像，可以设置额外的参数。未来我们会扩充更多的可控制参数，当前版本支持以下变量的设定。

### `GS_PASSWORD`
在你使用openGauss镜像的时候，必须设置该参数。该参数值不能为空或者不定义。该参数设置了openGauss数据库的超级用户omm以及测试用户gaussdb的密码。openGauss安装时默认会创建omm超级用户，该用户名暂时无法修改。测试用户gaussdb是在[entrypoint.sh](https://github.com/enmotech/enmotech-docker-opengauss/blob/master/1.0.1/entrypoint.sh)中自定义创建的用户。

openGauss镜像配置了本地信任机制，因此在容器内连接数据库无需密码，但是如果要从容器外部（其它主机或者其它容器）连接则必须要输入密码。

**openGauss的密码有复杂度要求，需要：密码长度8个字符及以上，必须同时包含英文字母大小写，数字，以及特殊符号**

### `GS_NODENAME`

指定数据库节点名称 默认为gaussdb

### `GS_USERNAME`

指定数据库连接用户名 默认为gaussdb

### `GS_PORT`
指定数据库端口，默认为5432。

## 从容器外部连接容器数据库
openGauss的默认监听启动在容器内的5432端口上，如果想要从容器外部访问数据库，则需要在`docker run`的时候指定`-p`参数。比如以下命令将允许使用8888端口访问容器数据库。
```console
$ docker run --name opengauss --privileged=true -d -e GS_PASSWORD=Enmo@123 -p 8888:5432 enmotech/opengauss:latest
```
在上述命令正常启动容器数据库之后，可以通过外部的gsql进行数据库访问。
```console
$ gsql -d postgres -U gaussdb -W'Enmo@123' -h your-host-ip -p8888
```


## 持久化存储数据
容器一旦被删除，容器内的所有数据和配置也均会丢失，而从镜像重新运行一个容器的话，则所有数据又都是呈现在初始化状态，因此对于数据库容器来说，为了防止因为容器的消亡或者损坏导致的数据丢失，需要进行持久化存储数据的操作。通过在`docker run`的时候指定`-v`参数来实现。比如以下命令将会指定将openGauss的所有数据文件存储在宿主机的/enmotech/opengauss下。

```console
$  docker run --name opengauss --privileged=true -d -e GS_PASSWORD=secretpassword@123 \
    -v /enmotech/opengauss:/var/lib/opengauss \
    enmotech/opengauss:latest
```

## 创建主从复制的openGauss容器
创建容器镜像后执行脚本 [create_master_slave.sh](https://github.com/enmotech/enmotech-docker-opengauss/blob/master/create_master_slave.sh)自动创建openGauss主从架构。
该脚本有多个自定义参数并设定默认值。  
OG_SUBNET (容器所在网段) [172.11.0.0/24]  
GS_PASSWORD (定义数据库密码)[Enmo@123]  
MASTER_IP (主库IP)[172.11.0.101]  
SLAVE_1_IP (备库IP)[172.11.0.102]  
MASTER_HOST_PORT (主库数据库服务端口)[5432]  
MASTER_LOCAL_PORT (主库通信端口)[5434]  
SLAVE_1_HOST_PORT (备库数据库服务端口)[6432]  
SLAVE_1_LOCAL_PORT (备库通信端口)[6434]  
MASTER_NODENAME (主节点名称)[opengauss_master]  
SLAVE_NODENAME （备节点名称）[opengauss_slave1]  

### 测试用例
```console
# docker pull enmotech/opengauss:1.0.1
# wget https://raw.githubusercontent.com/enmotech/enmotech-docker-opengauss/master/create_master_slave.sh
# chmod +x create_master_slave.sh 
# ./create_master_slave.sh 
Please input OG_SUBNET (容器所在网段) [172.11.0.0/24]: 
OG_SUBNET set 172.11.0.0/24
Please input GS_PASSWORD (定义数据库密码)[Enmo@123]: 
GS_PASSWORD set Enmo@123
Please input MASTER_IP (主库IP)[172.11.0.101]: 
MASTER_IP set 172.11.0.101
Please input SLAVE_1_IP (备库IP)[172.11.0.102]: 
SLAVE_1_IP set 172.11.0.102
Please input MASTER_HOST_PORT (主库数据库服务端口)[5432]: 
MASTER_HOST_PORT set 5432
Please input MASTER_LOCAL_PORT (主库通信端口)[5434]: 
MASTER_LOCAL_PORT set 5434
Please input SLAVE_1_HOST_PORT (备库数据库服务端口)[6432]: 
SLAVE_1_HOST_PORT set 6432
Please input SLAVE_1_LOCAL_PORT (备库通信端口)[6434]: 
SLAVE_1_LOCAL_PORT set 6434
Please input MASTER_NODENAME [opengauss_master]: 
MASTER_NODENAME set opengauss_master
Please input SLAVE_NODENAME [opengauss_slave1]: 
SLAVE_NODENAME set opengauss_slave1
Please input openGauss VERSION [1.0.1]: 
openGauss VERSION set 1.0.1
starting  
a70b46c7b2ddd1b6959403a0ac5b6783cf3f4100404fa628b8f055352a3e8567
OpenGauss Database Network Created.
e5430f16948639ac6a681e7f7db5ebbce8bf40c576e17ae412a3003f27b8ea14
OpenGauss Database Master Docker Container created.
bcb688c551b15d34196c249fdf934e4b8140a9181d6dde809c957405ec1ed29a
OpenGauss Database Slave1 Docker Container created.

验证主从状态

# docker exec -it opengauss_master /bin/bash
# su - omm
Last login: Thu Oct  1 23:19:49 UTC 2020 on pts/0
$ gs_ctl query -D /var/lib/opengauss/data/
[2020-10-01 23:21:27.685][316][][gs_ctl]: gs_ctl query ,datadir is -D "/var/lib/opengauss/data"  
 HA state:           
        local_role                     : Primary
        static_connections             : 1
        db_state                       : Normal
        detail_information             : Normal

 Senders info:       
        sender_pid                     : 258
        local_role                     : Primary
        peer_role                      : Standby
        peer_state                     : Normal
        state                          : Streaming
        sender_sent_location           : 0/3000550
        sender_write_location          : 0/3000550
        sender_flush_location          : 0/3000550
        sender_replay_location         : 0/3000550
        receiver_received_location     : 0/3000550
        receiver_write_location        : 0/3000550
        receiver_flush_location        : 0/3000550
        receiver_replay_location       : 0/3000550
        sync_percent                   : 100%
        sync_state                     : Sync
        sync_priority                  : 1
        sync_most_available            : On
        channel                        : 172.11.0.101:5434-->172.11.0.102:53786

 Receiver info:      
No information 
```

# License
Copyright (c) 2011-2020 Enmotech

许可证协议遵循GPL v3.0，你可以从下方获取协议的详细内容。

    https://github.com/enmotech/enmotech-docker-opengauss/blob/master/LICENSE
