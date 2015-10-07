#!/bin/bash

set -e -x

DOCKERNAME=coreos.zfs-builder

build() {
  docker build -t epflsti/${DOCKERNAME} .
}

autorun() {
  docker rm -f ${DOCKERNAME} 2>/dev/null || true
  docker run \
         --name ${DOCKERNAME} \
         -v /usr/share/coreos:/host/usr/share/coreos \
         epflsti/${DOCKERNAME} /build-zfs.sh
}

exec() {
  docker exec -it \
         --name ${DOCKERNAME} \
         -v /usr/share/coreos:/host/usr/share/coreos \
         epflsti/${DOCKERNAME} /bin/sh
}

interactive() {
  docker rm -f ${DOCKERNAME} 2>/dev/null || true
  docker run -it \
         --name ${DOCKERNAME} \
         -v /usr/share/coreos:/host/usr/share/coreos \
         epflsti/${DOCKERNAME} /bin/sh
}

eval "$@"

