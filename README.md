# 快速参考
- **维护者**:
[Enmotech OpenSource Team](https://github.com/enmotech)
- **哪里可以获取帮助**:
[墨天轮-openGauss](https://www.modb.pro/openGauss)

# 支持的tags和 `Dockerfile`链接
-	[`1.0.0`, `latest`](https://github.com/enmotech/enmotech-docker-opengauss/blob/master/1.0.0/dockerfile)

# 什么是openGauss


[https://opengauss.com/](https://opengauss.com/)

# 云和恩墨openGuass镜像的特点

# 如何使用本镜像

## 启动openGuass实例

```console
$ docker run --name opengauss --privileged=true -d -e GS_PASSWORD=secretpassword@123 enmotech/opengauss:latest
```

**openGauss的密码有复杂度要求，需要：密码长度8个字符以上，必须同时包含英文字母，数字，以及特殊符号 **

# 更多的可控制参数


## 环境变量
未来我们会扩充更多的可控制参数，当前版本支持以下变量的设定。

### `POSTGRES_PASSWORD`


# 从容器外部连接容器数据库
openGauss的默认监听启动在容器内的5432端口上，如果想要从容器外部访问数据库，则需要在`docker run`的时候指定`-p`参数。比如以下命令将允许使用8888端口访问容器数据库。
```console
$ docker run --name opengauss --privileged=true -d -e GS_PASSWORD=secretpassword@123 -p 8888:5432 enmotech/opengauss:latest
```
在上述命令正常启动容器数据库之后，可以通过外部的gsql进行数据库访问。
```console
$ gsql -d postgres -U omm -W'secretpassword@123' -h your-host-ip -p8888
```

# 持久化存储数据

If you remove the container all your data and configurations will be lost, and the next time you run the image the database will be reinitialized. To avoid this loss of data, you should mount a volume that will persist even after the container is removed.

For persistence you should mount a directory at the `/enmotech/opengauss` path. If the mounted directory is empty, it will be initialized on the first run.

```console
$  docker run --name opengauss --privileged=true -d -e GS_PASSWORD=secretpassword@123 \
    -v /enmotech/opengauss:/var/lib/opengauss \
    enmotech/opengauss:latest
```

## Setting up a streaming replication
// TODO@lee1057

# License
