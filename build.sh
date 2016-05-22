#!/bin/bash

set -e -x

DEPOT=registry.service.consul:5000
DOCKERNAME=cluster.coreos.zfs

build() {
  docker build -t ${DEPOT}/${DOCKERNAME} .
}

autorun() {
  docker rm -f ${DOCKERNAME} 2>/dev/null || true
  docker run \
         --name ${DOCKERNAME} \
         -v /usr/share/coreos:/host/usr/share/coreos \
         ${DEPOT}/${DOCKERNAME} /build-zfs.sh
}

exec() {
  docker exec -it ${DOCKERNAME} /bin/sh
}

interactive() {
  docker rm -f ${DOCKERNAME} 2>/dev/null || true
  docker run -it \
         --name ${DOCKERNAME} \
         -v /usr/share/coreos:/host/usr/share/coreos \
         ${DEPOT}/${DOCKERNAME} /bin/sh
}

eval "$@"

