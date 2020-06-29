FROM centos:7.6.1810

# TODO 需要更加构建平台来选择文件
COPY openGauss-1.0.0-CentOS-64bit.tar.bz2 .
ENV LANG en_US.utf8
# TODO 是否考虑时区

#RUN yum install -y epel-release

RUN set -eux; \
    groupadd -g 70 omm; \
    useradd -u 70 -g omm -d /home/omm omm; \
    yum install -y bzip2 bzip2-devel curl libaio && \
    mkdir -p /var/lib/opengauss && \
    mkdir -p /usr/local/opengauss && \
    tar -jxvf openGauss-1.0.0-CentOS-64bit.tar.bz2 -C /usr/local/opengauss && \
    mkdir -p /var/run/opengauss && chown -R omm:omm /var/run/opengauss && chmod 2777 /var/run/opengauss && \
    rm -rf openGauss-1.0.0-CentOS-64bit.tar.bz2 && yum clean all

RUN set -eux; \
    echo "export GAUSSHOME=/usr/local/opengauss"  >> /home/omm/.bashrc && \
    echo "export PATH=\$GAUSSHOME/bin:\$PATH " >> /home/omm/.bashrc && \
    echo "export LD_LIBRARY_PATH=\$GAUSSHOME/lib:\$LD_LIBRARY_PATH" >> /home/omm/.bashrc

ENV GOSU_VERSION 1.12
RUN set -eux; \
    gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && rm -r /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu

RUN mkdir /docker-entrypoint-initdb.d

ENV PGDATA /var/lib/opengauss/data

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh / # backwards compat

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 5432
CMD ["gaussdb"]
