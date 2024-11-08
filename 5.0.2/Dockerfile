FROM ubuntu:22.04 as builder

ARG TARGETARCH
ARG SOFTWARE_TYPE="Enterprise-Edition"

WORKDIR /warehouse

RUN set -eux; \
    if [ "$TARGETARCH" = "arm64" ]; then \
        echo "deb http://mirror.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy main restricted universe multiverse" >/etc/apt/sources.list && \
        echo "deb http://mirror.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-updates main restricted universe multiverse" >>/etc/apt/sources.list && \
        echo "deb http://mirror.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-backports main restricted universe multiverse" >>/etc/apt/sources.list && \
        echo "deb http://mirror.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-security main restricted universe multiverse" >>/etc/apt/sources.list && \
        echo "deb http://mirror.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-proposed main restricted universe multiverse" >>/etc/apt/sources.list; \
    elif [ "$TARGETARCH" = "amd64" ]; then \
        echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse" >/etc/apt/sources.list && \
        echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse" >>/etc/apt/sources.list && \
        echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse" >>/etc/apt/sources.list && \
        echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse" >>/etc/apt/sources.list; \
    fi && \
    mkdir -p /warehouse/opengauss && \
    apt-get update && apt-get install --yes --no-install-recommends  \
    wget \
    bzip2 \
    ca-certificates && \
    if [ "$TARGETARCH" = "arm64" ]; then \
        if [ "bash -x enhanced_build_images.sh -v 5.0.3 --platform linux/arm64,linux/amd64 --driver-opt env.http_proxy=172.25.160.1:7890 --driver-opt env.https_proxy=172.25.160.1:7890  --build-arg HTTPS_PROXY=http://172.25.160.1:7890 --build-arg HTTP_PROXY=http://172.25.160.1:7890" = "Enterprise-Edition" ]; then \
            wget --progress=bar:force:noscroll https://opengauss.obs.cn-south-1.myhuaweicloud.com/5.0.2/arm_2203/openGauss-5.0.2-openEuler-64bit-all.tar.gz -O /warehouse/openGauss.tar.bz2; \
            tar xf /warehouse/openGauss.tar.bz2;  \
            tar xf openGauss-5.0.2-openEuler-64bit.tar.bz2 -C /warehouse/opengauss; \
        elif [ "$SOFTWARE_TYPE" = "Simplified" ]; then \
            wget --progress=bar:force:noscroll https://opengauss.obs.cn-south-1.myhuaweicloud.com/5.0.2/arm_2203/openGauss-5.0.2-openEuler-64bit.tar.bz2 -O /warehouse/openGauss.tar.bz2; \
            tar xf openGauss.tar.bz2 -C /warehouse/opengauss; \
        else \
            wget --progress=bar:force:noscroll https://opengauss.obs.cn-south-1.myhuaweicloud.com/5.0.2/arm_2203/openGauss-Lite-5.0.2-openEuler-aarch64.tar.gz -O /warehouse/openGauss.tar.bz2; \
             tar xf /warehouse/openGauss.tar.bz2;  \
             tar xf openGauss-Lite-5.0.2-openEuler-aarch64.bin -C /warehouse/opengauss; \
        fi \
    elif [ "$TARGETARCH" = "amd64" ]; then \
        if [ "$SOFTWARE_TYPE" = "Enterprise-Edition" ]; then \
            wget --progress=bar:force:noscroll https://opengauss.obs.cn-south-1.myhuaweicloud.com/5.0.2/x86_openEuler_2203/openGauss-5.0.2-openEuler-64bit-all.tar.gz -O /warehouse/openGauss.tar.bz2; \
            tar xf /warehouse/openGauss.tar.bz2;  \
            tar xf openGauss-5.0.2-openEuler-64bit.tar.bz2 -C /warehouse/opengauss; \
        elif [ "$SOFTWARE_TYPE" = "Simplified" ]; then \
            wget --progress=bar:force:noscroll https://opengauss.obs.cn-south-1.myhuaweicloud.com/5.0.2/x86_openEuler_2203/openGauss-5.0.2-openEuler-64bit.tar.bz2 -O /warehouse/openGauss.tar.bz2; \
            tar xf openGauss.tar.bz2 -C /warehouse/opengauss; \
        else \
            wget --progress=bar:force:noscroll https://opengauss.obs.cn-south-1.myhuaweicloud.com/5.0.2/x86_openEuler_2203/openGauss-Lite-5.0.2-openEuler-x86_64.tar.gz -O /warehouse/openGauss.tar.bz2; \
            tar xf /warehouse/openGauss.tar.bz2;  \
            tar xf openGauss-Lite-5.0.2-openEuler-x86_64.bin -C /warehouse/opengauss; \
        fi \
    fi && \
    rm -f /warehouse/openGauss.tar.bz2 && chmod -R +rx /warehouse/opengauss



FROM ubuntu:22.04

ARG TARGETARCH

ENV LANG en_US.utf8
ENV GAUSSLOG /home/omm/pg_log
ENV PGDATA /var/lib/opengauss/data
ENV PGDATABASE postgres

RUN set -eux; \
    apt-get update && apt-get install --yes --no-install-recommends \
    tzdata \
    vim \
    libltdl7 \
    libc6 \
    ncat \
    gosu \
    bzip2 \
    procps \
    locales \
    iputils-ping \
    libaio-dev \
    libkeyutils-dev \
    libreadline-dev; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/*; \
    groupadd -g 70 omm; \
    useradd -u 70 -g omm -m -s /bin/bash omm; \
    mkdir -p /var/lib/opengauss; \
    mkdir -p /var/run/opengauss; \
    mkdir /docker-entrypoint-initdb.d; \
    chown omm:omm /var/lib/opengauss /home/omm /var/run/opengauss /docker-entrypoint-initdb.d; \
    echo "export GAUSSLOG=/home/omm/pg_log" >> /home/omm/.profile; \
    echo "export GAUSSHOME=/usr/local/opengauss" >> /home/omm/.profile; \
    echo "export PGDATA=/var/lib/opengauss/data" >> /home/omm/.profile; \
    echo "export PATH=\$GAUSSHOME/bin:\$PATH " >> /home/omm/.profile; \
    echo "export LD_LIBRARY_PATH=\$GAUSSHOME/lib:\$LD_LIBRARY_PATH" >> /home/omm/.profile; \
    locale-gen en_US.UTF-8 && \
    if [ "$TARGETARCH" = "arm64" ];then \
        ln -s /lib/aarch64-linux-gnu/libreadline.so.8.0 /lib/aarch64-linux-gnu/libreadline.so.7; \
    elif [ "$TARGETARCH" = "amd64" ];then \
        ln -s /lib/x86_64-linux-gnu/libreadline.so.8.0 /lib/x86_64-linux-gnu/libreadline.so.7; \
    fi


COPY entrypoint.sh /usr/local/bin/
COPY --chown=omm:omm --from=builder /warehouse/opengauss /usr/local/opengauss
RUN chmod 755 /usr/local/bin/entrypoint.sh && ln -s /usr/local/bin/entrypoint.sh /

ENTRYPOINT ["entrypoint.sh"]
EXPOSE 5432
CMD ["gaussdb"]