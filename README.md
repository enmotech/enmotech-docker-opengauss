# What is openGauss
// TODO@kamusis
> copy contents from openGauss official site, should be completed after 2020/6/30

[https://opengauss.com/](https://opengauss.com/)

# TL;DR;

```console
$ docker run --name opengauss enmotech/opengauss:latest
```

## Docker Compose

```console
$ curl -sSL https://raw.githubusercontent.com/enmotech/enmotech-docker-opengauss/master/docker-compose.yml > docker-compose.yml
$ docker-compose up -d
```

# Why use Enmotech Images?
// TODO@kamusis
云和恩墨在openGuass的核心基础上，为周边增加了全套工具集。使用云和恩墨的openGauss容器镜像，可以获得正式的服务支持。

# Supported tags and respective `Dockerfile` links

# Get this image

The recommended way to get the Enmotech openGauss Docker Image is to pull the prebuilt image from the [Docker Hub Registry](https://hub.docker.com/r/enmotech/opengauss).

```console
$ docker pull enmotech/opengauss:latest
```

# Persisting your database

If you remove the container all your data and configurations will be lost, and the next time you run the image the database will be reinitialized. To avoid this loss of data, you should mount a volume that will persist even after the container is removed.

For persistence you should mount a directory at the `/enmotech/opengauss` path. If the mounted directory is empty, it will be initialized on the first run.

```console
$ docker run \
    -v /path/to/opengauss-persistence:/enmotech/opengauss \
    enmotech/opengauss:latest
```

## Setting up a streaming replication
// TODO@lee1057
// 完成创建主从高可用架构
