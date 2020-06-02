# Audit lee
# Version 1.0
FROM scratch
ADD centos-7-docker.tar.xz /
ADD Python-3.6.5.tar.xz /usr/local/
LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.name="CentOS Base Image" \
    org.label-schema.vendor="CentOS" \
    org.label-schema.license="GPLv2" \
    org.label-schema.build-date="20181204"
RUN yum install -y wget openssl-devel bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel gcc gcc-c++ make telnet openssh-clients openssh-server net-tools&& \
     swapoff -a && \
     /usr/local/Python-3.6.5/configure --prefix=/usr/local/python3 && \
     make && make install && \
     rm -f /usr/bin/python && rm -f /usr/local/python3/bin/pip3  && ln -s /usr/local/python3/bin/python3  /usr/bin/python && \
     ln -s /usr/local/python3/bin/pip3  /usr/bin/pip3  && \
     sed -i "s/\/usr\/bin\/python/\/usr\/bin\/python2/g" /usr/bin/yum && \ 
     sed -i "s/\/usr\/bin\/python/\/usr\/bin\/python2/g" /usr/libexec/urlgrabber-ext-down && \ 
     mkdir -p /opt/software/openGauss  && \
     chmod 755 -R /opt/software
COPY clusterconfig.xml /opt/software/openGauss/
ADD openGauss-1.0.0-CentOS-64bit.tar.gz /opt/software/openGauss/
ADD libpython3.6m.so.1.0 /usr/lib64/libpython3.6m.so.1.0
CMD systemctl start sshd
RUN groupadd dbgrp  && useradd  omm -g dbgrp -G dbgrp && echo "123456" |passwd --stdin omm && \
    sed -i "s/enmotest/$HOSTNAME/g" /opt/software/openGauss/clusterconfig.xml && \ 
    /opt/software/openGauss/script/gs_preinstall -U omm -G dbgrp -X /opt/software/openGauss/clusterconfig.xml --non-interactive && \
    su - omm -c "sed -i 's/shared_buffers = 1GB/shared_buffers = 100MB/' /gaussdb/data/db1/postgresql.conf" && \
    su - omm -c "sed -i 's/bulk_write_ring_size = 2GB/bulk_write_ring_size = 1GB/' /gaussdb/data/db1/postgresql.conf" && \
    su - omm -c "sed -i 's/cstore_buffers = 1GB/cstore_buffers = 100MB/' /gaussdb/data/db1/postgresql.conf" && \
    su - omm -c "/opt/software/openGauss/script/gs_install -X /opt/software/openGauss/clusterconfig.xml"
EXPOSE  26000 26001 22
