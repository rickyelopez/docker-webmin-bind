ARG UBUNTU_TAG=noble-20250404
FROM ubuntu:${UBUNTU_TAG} AS add-apt-repositories

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,DL3015
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends gnupg curl ca-certificates \
    && curl -Ss https://download.webmin.com/developers-key.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/webmin.gpg \
    && echo "deb [signed-by=/etc/apt/trusted.gpg.d/webmin.gpg] https://download.webmin.com/download/newkey/repository stable contrib" | tee /etc/apt/sources.list.d/webmin.list

FROM ubuntu:${UBUNTU_TAG}

LABEL maintainer="rickyelopez"

COPY --from=add-apt-repositories /etc/apt/trusted.gpg.d /etc/apt/trusted.gpg.d

COPY --from=add-apt-repositories /etc/apt/sources.list /etc/apt/sources.list
COPY --from=add-apt-repositories /etc/apt/sources.list.d /etc/apt/sources.list.d

ARG BIND_VERSION=1:9.18.30-0ubuntu0.24.04.2
ARG WEBMIN_VERSION=2.400

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN  apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    dnsutils \
    tzdata \
    cron \
    && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3015
RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    bind9-host=${BIND_VERSION} \
    bind9=${BIND_VERSION} \
    webmin=${WEBMIN_VERSION} \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp 10000/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/named"]
