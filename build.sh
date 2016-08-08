#!/bin/bash

set -e -x

DEPOT=registry.service.consul:5000
DOCKERNAME=cluster.coreos.zfs

build_base() {
  DOCKER_IMAGE_BASE=${DEPOT}/${DOCKERNAME}.base
  docker pull ${DOCKER_IMAGE_BASE} || true
  docker build -t ${DOCKER_IMAGE_BASE} zfs.base/
  docker push ${DOCKER_IMAGE_BASE} || true
}

build_this_version() {
  cp /usr/share/coreos/lsb-release zfs/
  . zfs/lsb-release
  DOCKER_IMAGE_THISVERSION=${DEPOT}/${DOCKERNAME}:${DISTRIB_RELEASE}
  docker pull ${DOCKER_IMAGE_THISVERSION} || true
  docker build -t ${DOCKER_IMAGE_THISVERSION} zfs/
  docker push ${DOCKER_IMAGE_THISVERSION} || true
}

if [ -n "$1" ]; then
    eval "$@"
else
    build_base
    build_this_version
fi

