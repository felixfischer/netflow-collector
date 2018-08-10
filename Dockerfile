FROM ubuntu:18.04

ENV LANG C.UTF-8

## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

## preesed tzdata, update package index, upgrade packages and install needed software
RUN echo "tzdata tzdata/Areas select Europe" > /tmp/preseed.txt; \
    echo "tzdata tzdata/Zones/Europe select Berlin" >> /tmp/preseed.txt; \
    debconf-set-selections /tmp/preseed.txt \
    && rm -f /etc/timezone \
    && rm -f /etc/localtime \
    && apt-get update \
    && apt-get dist-upgrade \
    && apt-get install --no-install-recommends --no-install-suggests -y -q \
        gnupg \
        lsb-release \
        tzdata \
        wget \
    && cd /tmp \
    && wget --quiet http://apt-stable.ntop.org/18.04/all/apt-ntop-stable.deb \
    && dpkg -i /tmp/apt-ntop-stable.deb \
    && apt-get clean all \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y -q \
        nprobe \
        ntopng \
        ntopng-data \
        pfring \
    && apt-get clean \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf /var/lib/apt/lists/*

ADD run.sh /
ADD redis.conf /etc/redis/redis.conf
ADD nprobe.conf /etc/nprobe/nprobe.conf

VOLUME ["/var/lib/redis", "/var/lib/ntop"]

EXPOSE 2055 3000

ENTRYPOINT ["/bin/bash", "/run.sh"]
CMD ["-w", "3000", "-i", "tcp://127.0.0.1:5556", "--local-networks", "192.168.0.0/16"]
