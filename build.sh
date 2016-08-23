#!/bin/bash

set -e -x

DEPOT=registry.service.consul:5000
DOCKERNAME=cluster.coreos.zfs
. /usr/share/coreos/lsb-release
DOCKER_IMAGE_THISVERSION=${DEPOT}/${DOCKERNAME}:${DISTRIB_RELEASE}

build_base() {
  DOCKER_IMAGE_BASE=${DEPOT}/${DOCKERNAME}.base
  docker pull ${DOCKER_IMAGE_BASE} || true
  docker build -t ${DOCKER_IMAGE_BASE} zfs.base/
  docker push ${DOCKER_IMAGE_BASE} || true
}

build_this_version() {
  cp /usr/share/coreos/lsb-release zfs/
  docker pull ${DOCKER_IMAGE_THISVERSION} || true
  docker build -t ${DOCKER_IMAGE_THISVERSION} zfs/
  docker push ${DOCKER_IMAGE_THISVERSION} || true
}

export_payload() {
    docker run --rm -v $PWD:/export ${DOCKER_IMAGE_THISVERSION} \
          tar zcf /export/linux-zfs-${DISTRIB_RELEASE}.tgz \
          /usr/portage/packages/sys-fs/ /lib/modules
}

explore() {
    docker run --rm -v $PWD:/export -it ${DOCKER_IMAGE_THISVERSION} /bin/bash
}
           
if [ -n "$1" ]; then
    eval "$@"
else
    build_base
    build_this_version
    export_payload
fi

