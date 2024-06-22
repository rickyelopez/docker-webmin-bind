FROM ubuntu:noble-20240605 AS add-apt-repositories

# hadolint ignore=DL3008,DL3015
RUN apt-get update \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg --no-install-recommends \
    && apt-get install -y curl \
    && apt-key adv --fetch-keys https://download.webmin.com/developers-key.asc \
    && echo "deb https://download.webmin.com/download/newkey/repository stable contrib" >> /etc/apt/sources.list

FROM ubuntu:noble-20240605
LABEL maintainer="rickyelopez"

ENV BIND_USER=bind
ENV BIND_GROUP=bind
ENV BIND_VERSION=1:9.18.24-0ubuntu5
ENV WEBMIN_VERSION=2.111
ENV DATA_DIR=/data
ENV WEBMIN_INIT_SSL_ENABLED=""
ENV TZ=""

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]
# hadolint ignore=DL3005,DL3008,DL3008
RUN  apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    dnsutils \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY --from=add-apt-repositories /etc/apt/trusted.gpg /etc/apt/trusted.gpg
COPY --from=add-apt-repositories /etc/apt/sources.list /etc/apt/sources.list

# hadolint ignore=DL3015
RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
    && apt-get update \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    bind9=${BIND_VERSION} \
    bind9-host=${BIND_VERSION} \
    webmin=${WEBMIN_VERSION} \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp 10000/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/named"]
