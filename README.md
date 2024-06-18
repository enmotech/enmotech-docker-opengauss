# Quick Reference

- **Maintainers**:
  [EnmoTech OpenSource Team](https://github.com/enmotech)
- **Where to get help**:
  [Mo Tian Lun-openGauss](https://www.modb.pro/openGauss)



***If you are attempting to run a container of openGauss version 5.0 or later on macOS or Windows, you should use the [`enmotech/opengauss-lite`](https://hub.docker.com/r/enmotech/opengauss-lite) version. This is because since version 5.0, the openGauss EE container cannot start up properly on macOS or Windows. However, there are no issues when running it on Linux.***



# Supported Tags and `Dockerfile` Links

- [`latest`](https://hub.docker.com/layers/enmotech/opengauss/latest/images/sha256-55a0c6300b84fb79034d2f9d9924557a0d040c2d9d33e51f8ae8a1eb097dad1e?context=repo)
- [`5.1.0`](https://hub.docker.com/layers/enmotech/opengauss/5.1.0/images/sha256-0e57f4bc7352f8c8614d1883a0c4cc9199bf7b35f66ed89d0c62f45841da30bc?context=repo)
- [`5.0.1`](https://hub.docker.com/layers/enmotech/opengauss/5.0.1/images/sha256-4c294a33fd255b618f4d1549096ab5ae230f759d0213beabf90d099a3dcd9c07?context=repo)
- [`5.0.0`](https://hub.docker.com/layers/enmotech/opengauss/5.0.0/images/sha256-55a0c6300b84fb79034d2f9d9924557a0d040c2d9d33e51f8ae8a1eb097dad1e?context=repo)
- [`3.1.1`](https://hub.docker.com/layers/enmotech/opengauss/3.1.1/images/sha256-95a518d150d4d1badcc2e72eae699d5ad82692d90c0c3eed0ec2ab5faec515d6?context=repo)
- [`3.1.0`](https://hub.docker.com/layers/enmotech/opengauss/3.1.0/images/sha256-b2be542351fa26f3e6b3aabe212f470b9dfeaf7350e03e98c83bca77c77320ea?context=repo)
- [`3.0.3`](https://hub.docker.com/layers/enmotech/opengauss/3.0.3/images/sha256-1608795fb4c376bf1b078adf56e7e8b5e7ee9eaf4c0951fdd85ea3ca19569007?context=repo)
- [`3.0.0`](https://hub.docker.com/layers/opengauss/enmotech/opengauss/3.0.0/images/sha256-33a4f621386c6dfaa21110e1e0a8d42b16a7231591127f9553d6854cbebc3440?context=explore)
- [`2.1.0`](https://hub.docker.com/layers/enmotech/opengauss/2.1.0/images/sha256-cd5295251e13f91ba28495f63a93587879843c34e49595caa41f6aab5b689db1?context=explore)
- [`2.0.1`](https://hub.docker.com/layers/enmotech/opengauss/2.0.1/images/sha256-6484016276f41d600f954313d3498e9db0cc385855dc1aaff6b9da685aa48de1?context=explore)
- [`2.0.0`](https://hub.docker.com/layers/enmotech/opengauss/2.0.0/images/sha256-2e43ab3306bf0300079726718d8b27304212eca5b49d0be418eec12d4f2ca105?context=explore)
- [`1.1.0`](https://hub.docker.com/layers/enmotech/opengauss/1.1.0/images/sha256-004bfdb7c883d22b7731e14995c4a4ff1fe254f47cec3ddca088bea2fd133543?context=explore)
- [`1.0.1`](https://hub.docker.com/layers/enmotech/opengauss/1.0.1/images/sha256-9e82b00802e8bd7a1b78344bbc77cc593303ca0b0c5bbb041192b360a5c89ccf?context=explore)
- [`1.0.0`](https://hub.docker.com/layers/enmotech/opengauss/1.0.0/images/sha256-07e7a0e0c07df7c9151bd8038883e40546a9705b61b63373ebaf70dbc738c40c?context=explore)

# About openGauss

openGauss is an open-source relational database management system released under the Mulan PSL v2 license. The openGauss kernel was originally derived from PostgreSQL and deeply integrates Huawei's extensive experience in the database field, continuously building competitive features tailored to enterprise needs. openGauss is also an open-source, free database platform that encourages community contributions and collaboration.

openGauss Community Official Website: [https://opengauss.org/](https://opengauss.org/)

![logo](https://i.loli.net/2020/12/16/4xLt2QGOfcAgzKw.png)

# Features of Enmotech openGauss Image

* Enmotech closely tracks changes in the openGauss source code and releases new versions of the image promptly.
* Enmotech's cloud database, virtual machine database, and container version database all use the same best practice initialization configuration, ensuring a nearly identical experience when dealing with various requirements.
* Enmotech continuously releases various images for different CPU architectures (x86 or ARM) and operating systems.

**Currently supports x86-64 and ARM64 architectures, automatically determined based on the machine architecture when obtaining the image.**

From version 5.0 (including 5.0):

- Enterprise edition and Lite edition separated. [`enmotech/opengauss`](https://hub.docker.com/r/enmotech/opengauss/tags) is Enterprise edition, [`enmotech/opengauss-lite`](https://hub.docker.com/r/enmotech/opengauss-lite/tags) is Lite edition.

From version 3.0 (including 3.0):

- The container uses the [openGauss Database Lite version](https://opengauss.org/zh/docs/3.0.0-lite/docs/Releasenotes/%E7%89%88%E6%9C%AC%E4%BB%8B%E7%BB%8D.html)
- Default startup with idle memory less than 200M
- Added basic commands such as vi, ps, etc.

From version 2.0 (including 2.0):

- openGauss for x86-64 architecture runs on the [Ubuntu 18.04 operating system](https://ubuntu.com/)
- openGauss for ARM64 architecture runs on the [Debian 10 operating system](https://www.debian.org/)

Before version 1.1.0 (including 1.1.0):

- openGauss for x86-64 architecture runs on the [CentOS 7.6 operating system](https://www.centos.org/)
- openGauss for ARM64 architecture runs on the [openEuler 20.03 LTS operating system](https://openeuler.org/zh/)

# How to Use This Image

## Start an openGauss Instance

```console
$ docker run --name opengauss --privileged=true -d -e GS_PASSWORD=Enmo@123 enmotech/opengauss:latest
```

## Environment Variables

To use the openGauss image more flexibly, additional parameters can be set. More controllable parameters will be added in future versions. The current version supports the following variables.

### `GS_PASSWORD`

This parameter must be set when using the openGauss image. The value cannot be empty or undefined. This parameter sets the password for the openGauss database superuser `omm` and the test user `gaussdb`. The `omm` superuser is created by default during openGauss installation and the username cannot be changed at this time. The test user `gaussdb` is a custom-created user in the [entrypoint.sh](https://github.com/enmotech/enmotech-docker-opengauss/blob/master/1.0.1/entrypoint.sh).

The openGauss image is configured with local trust mechanism, so no password is required to connect to the database within the container. However, if connecting from outside the container (other hosts or other containers), a password must be entered.

**openGauss password complexity requirements: the password must be at least 8 characters long and contain uppercase and lowercase English letters, numbers, and special characters.**

### `GS_NODENAME`

Specifies the database node name. The default is `gaussdb`.

### `GS_USERNAME`

Specifies the database connection username. The default is `gaussdb`.

### `GS_PORT`

Specifies the database port. The default is 5432.

## Connecting to the Container Database from Outside the Container

openGauss listens on port 5432 within the container by default. To access the database from outside the container, specify the `-p` parameter when running `docker run`. For example, the following command allows access to the container database using port 15432.

```console
$ docker run --name opengauss --privileged=true -d -e GS_PASSWORD=Secretpassword@123 -p 15432:5432 enmotech/opengauss:latest
```

After successfully starting the container database with the above command, you can access the database using `gsql` from outside.

```console
$ gsql -d postgres -U gaussdb -W'Secretpassword@123' -h your-host-ip -p15432
```

## Persistent Storage Data

Once a container is deleted, all data and configurations within the container will also be lost. If you run a container from the image again, all data will be in the initial state. Therefore, for database containers, to prevent data loss due to the container's demise or damage, persistent storage of data is required. This can be achieved by specifying the `-v` parameter when running `docker run`. For example, the following command will specify storing all data files of openGauss on the host machine at /enmotech/opengauss. The `-u root` parameter is used to specify that the script is executed as the root user when the container starts, otherwise, there will be permission issues in creating the data file directory.

Note: If using podman, there will be a target path check, and the target path on the host machine needs to be created in advance.

```console
$ mkdir -p /enmotech/opengauss
$ docker run --name opengauss --privileged=true -d -e GS_PASSWORD=Secretpassword@123 \
    -v /enmotech/opengauss:/var/lib/opengauss  -u root -p 15432:5432 \
    enmotech/opengauss:latest
```

## Create Master-Slave Replication openGauss Container

1. Pull the container image
2. Run the script [create_master_slave.sh](https://github.com/enmotech/enmotech-docker-opengauss/blob/master/create_master_slave.sh), enter the required parameters as prompted, or directly use the default values to automatically create two containers with a one-master-one-slave architecture of openGauss.

The above script has multiple custom parameters, the following are the parameter names (explanation) [default value].

> `OG_SUBNET` (Container subnet) [172.11.0.0/24]  
> `GS_PASSWORD` (Define database password) [Enmo@123]  
> `MASTER_IP` (Master database IP) [172.11.0.101]  
> `SLAVE_1_IP` (Slave database IP) [172.11.0.102]  
> `MASTER_HOST_PORT` (Master database service port) [5432]  
> `MASTER_LOCAL_PORT` (Master communication port) [5434]  
> `SLAVE_1_HOST_PORT` (Slave database service port) [6432]  
> `SLAVE_1_LOCAL_PORT` (Slave communication port) [6434]  
> `MASTER_NODENAME` (Master node name) [opengauss_master]  
> `SLAVE_NODENAME` (Slave node name) [opengauss_slave1]  

### Usage Example

#### Pull the Image

```console
# docker pull enmotech/opengauss:latest
```

#### Get and Run the Script to Create Master-Slave Containers

```console
# wget https://raw.githubusercontent.com/enmotech/enmotech-docker-opengauss/master/create_master_slave.sh
# chmod +x create_master_slave.sh 
# ./create_master_slave.sh 
Please input OG_SUBNET (Container subnet) [172.11.0.0/24]: 
OG_SUBNET set 172.11.0.0/24
Please input GS_PASSWORD (Define database password) [Enmo@123]: 
GS_PASSWORD set Enmo@123
Please input MASTER_IP (Master database IP) [172.11.0.101]: 
MASTER_IP set 172.11.0.101
Please input SLAVE_1_IP (Slave database IP) [172.11.0.102]: 
SLAVE_1_IP set 172.11.0.102
Please input MASTER_HOST_PORT (Master database service port) [5432]: 
MASTER_HOST_PORT set 5432
Please input MASTER_LOCAL_PORT (Master communication port) [5434]: 
MASTER_LOCAL_PORT set 5434
Please input SLAVE_1_HOST_PORT (Slave database service port) [6432]: 
SLAVE_1_HOST_PORT set 6432
Please input SLAVE_1_LOCAL_PORT (Slave communication port) [6434]: 
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
```

#### Verify Master-Slave Status

```
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

Copyright (c) 2011-2024 Enmotech

The license agreement follows GPL v3.0, and you can get the detailed content of the agreement from the link below.

    https://github.com/enmotech/enmotech-docker-opengauss/blob/master/LICENSE

# About EnmoTech

EnmoTech is an Intelligent Data Technology provider established in 2011, headquartered in Beijing, with offices covering 35 regions globally including Hong Kong, Singapore and Sydney. Since its inception, EnmoTech has focused continuously on innovating and developing solutions for data and databases. Our range of solutions include HTAP DBMS, software defined distributed storage, database deployment, performance management and intelligent data analytics. More than 3,000 corporate clients with more than 50,000 business systems has been served and managed by EnmoTech. Learn more at www.emotech.com or contact apacmarketing@enmotech.com 
