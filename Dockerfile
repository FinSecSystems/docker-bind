FROM ubuntu:focal AS add-apt-repositories

RUN cat /etc/resolv.conf

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg
# && apt-key adv --fetch-keys http://www.webmin.com/jcameron-key.asc \
RUN apt-get install -y curl

RUN curl -sSL http://www.webmin.com/jcameron-key.asc | apt-key add -

RUN echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list

FROM ubuntu:focal

LABEL maintainer="sameer@damagehead.com"

ENV BIND_USER=bind \
    BIND_VERSION=9.16.1 \
    WEBMIN_VERSION=1.984 \
    DATA_DIR=/data

COPY --from=add-apt-repositories /etc/apt/trusted.gpg /etc/apt/trusted.gpg

COPY --from=add-apt-repositories /etc/apt/sources.list /etc/apt/sources.list

RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      bind9=1:${BIND_VERSION}* bind9-host=1:${BIND_VERSION}* dnsutils \
      webmin=${WEBMIN_VERSION}* curl

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mdadm

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y smartmontools

RUN  rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp 10000/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/named"]
