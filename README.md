# [rickyelopez/webmin-bind](https://hub.docker.com/r/rickyelopez/webmin-bind)

A fork of [elmerfds/docker-bind](https://github.com/elmerfds/docker-bind),
which is a fork of [sameersbn/bind](https://github.com/sameersbn/docker-bind).
This fork simply updates the ubuntu, webmin, and bind versions used for the container.
It also adds `cron` so that you can configure automatic zone resigning.  

**NOTE** This fork has **NOT** been tested extensively, or really even much at all. I'm using it, but that's pretty much it.  
I make no claims that it is compatible with the `elmerfds` fork, or that it is stable in any capacity.  
Backup your configuration before switching to this image.  
Use at your own peril.

## Switching from `elmerfs/bind`

**You should back up your `data` dir before making this switch in case something goes wrong**

After backing up your config, simply switch the `image` key in `compose.yml` to use `rickyelopez/webmin-bind`,
and bring up the service as you normally do (e.g. with `docker compose up -d`).
After starting up, webmin automatically detects a new version of the base OS,
and presents a button on the dashboard to update its internal configuration.

From the minimal testing I have done, switching to this image from `elmerfds/bind` only required modifying `named.conf` to remove some
configuration parameters which had been deprecated in the newer version of `bind` used in this container. If you end up in this position,
the log (which you can access using `docker compose logs bind --tail=20 -f`, for example) will tell you which parts of your `named.conf`
need to be corrected.

Alternatively, you could start the container and check the configuration from within it:
```sh
docker compose run --rm webmin_bind /bin/bash
named-checkconf /etc/bind/named.conf
```

which should tell you exactly what you need to change. For example:

```sh
docker compose run --rm webmin_bind /bin/bash
root@bind:/# named-checkconf /etc/bind/named.conf
/etc/bind/named.conf:12: unknown option 'dnssec-enable'
```

## Notes from `elmerfds`' fork:
A fork of [sameersbn/bind](https://github.com/sameersbn/docker-bind) repo, what's different?
- Multiarch Support: 
  * amd64
  * armv7, arm64 i.e. supports RPi 3/4
- Running on Ubuntu Hirsute
- Bind: 9.16.8
- Webmin: Always pulls latest (during image build)
- Added Timezone (TZ) support
- Image auto-builds on schedule (every Sat 00:00 BST)
- Ubuntu updates will be applied during each scheduled build
- Reverse Proxy friendly ([utkuozdemir/docker-bind](https://github.com/utkuozdemir/docker-bind/tree/webmin-reverse-proxy-config))
- Fixes to [utkuozdemir/docker-bind](https://github.com/utkuozdemir/docker-bind/tree/webmin-reverse-proxy-config)'s 'Reverse Proxy friendly' update.
  * Cleanup of config & miniserv.conf when variables are used & then removed
  * Removing duplicate entries to config & miniserv.conf
 
## Contents
- [Introduction](#introduction)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)

# Introduction

Docker container image for [BIND](https://www.isc.org/downloads/bind/) DNS server bundled with the [Webmin](http://www.webmin.com/) interface.

BIND is open source software that implements the Domain Name System (DNS) protocols for the Internet. It is a reference implementation of those protocols, but it is also production-grade software, suitable for use in high-volume and high-reliability applications.

# Getting started

**Tags**

| Tag      | Description  | Build Status                                                                                                      |
| ---------|--------------|-------------------------------------------------------------------------------------------------------------------|
|  latest  | main/stable  | ![Docker Build Main](https://github.com/rickyelopez/docker-webmin-bind/workflows/Docker%20Build%20Main/badge.svg) |

## Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/rickyelopez/webmin-bind) and is the recommended method of installation.

```bash
docker pull rickyelopez/webmin-bind
```

Alternatively you can build the image yourself.

```bash
docker build -t rickyelopez/webmin-bind github.com/rickyelopez/docker-webmin-bind
```

## Quickstart

Docker Run:

```bash
docker run --name bind -d --restart=always \
  -p 53:53/tcp -p 53:53/udp -p 10000:10000/tcp \
  -v /path/to/bind/data:/data \
  rickyelopez/webmin-bind
```

OR

Docker Compose

```
    bind:
        container_name: bind
        hostname: bind
        network_mode: bridge
        image: rickyelopez/webmin-bind
        restart: unless-stopped
        ports:
            - "53:53/tcp"
            - "53:53/udp"
            - 10000:10000/tcp
        volumes:
            - /path/to/bind/data:/data
        environment:
            - WEBMIN_ENABLED=true
            - WEBMIN_INIT_SSL_ENABLED=false
            - WEBMIN_INIT_REFERERS=dns.domain.com
            - WEBMIN_INIT_REDIRECT_PORT=10000
            - ROOT_PASSWORD=password
            - TZ=Europe/London
```

When the container is started the [Webmin](http://www.webmin.com/) service is also started and is accessible from the web browser at https://serverIP:10000. Login to Webmin with the username `root` and password `password`. Specify `--env ROOT_PASSWORD=secretpassword` on the `docker run` command to set a password of your choosing. The launch of Webmin can be disabled if not required. 

### - Parameters

Container images are configured using parameters passed at runtime (such as those above). 

| Parameter | Function |
| :----: | --- |
| `-p 53:53/tcp` `-p 53:53/udp` | DNS TCP/UDP port|
| `-p 10000/tcp` | Webmin port |
| `-e WEBMIN_ENABLED=true` | Enable/Disable Webmin (true/false) |
| `-e ROOT_PASSWORD=password` | Set an initial password for Webmin root. Has no effect after a password has been set on first startup. Has no effect when the launch of Webmin is disabled.  |
| `-e WEBMIN_INIT_SSL_ENABLED=false` | Enable/Disable Webmin SSL (true/false). If Webmin should be served via SSL or not. Defaults to `true`. |
| `-e WEBMIN_INIT_REFERERS` | Enable/Disable Webmin SSL (true/false). Sets the allowed referrers to Webmin. Set this to your domain name of the reverse proxy. Example: `mywebmin.example.com`. Defaults to empty (no referrer)|
| `-e WEBMIN_INIT_REDIRECT_PORT` | The port Webmin is served from. Set this to your reverse proxy port, such as `443`. Defaults to `10000`. |
| `-e WEBMIN_INIT_REDIRECT_SSL` | Enable/Disable Webmin SSL redirection after login (true/false). Set this to `true` if behind a SSL terminator. Defaults to `false`|
| `-e BIND_EXTRA_FLAGS` | Default set to -g |
| `-v /data` | Mount data directory for persistent config  |
| `-e TZ=Europe/London` | Specify a timezone to use e.g. Europe/London |
