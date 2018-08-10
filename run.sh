#!/bin/bash
set -e

/etc/init.d/redis-server start

# chmod -R 777 /var/lib/redis
chown -R nobody /var/lib/ntop

nprobe --daemon-mode --zmq "tcp://*:5556" -i none -n none --collector-port 2055
ntopng --community -d /var/lib/ntop "$@"
