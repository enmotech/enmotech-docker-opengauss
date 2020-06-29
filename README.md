# 快速参考
- **维护者**:
[Enmotech OpenSource Team](https://github.com/enmotech)
- **哪里可以获取帮助**:
[墨天轮-openGauss](https://www.modb.pro/openGauss)

# 支持的tags和 `Dockerfile`链接
-	[`1.0.0`, `latest`](https://github.com/docker-library/postgres/blob/88173efa530f1a174a7ea311c5b6ee5e383f68bd/12/Dockerfile)

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
