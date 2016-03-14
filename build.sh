#!/bin/bash

set -e -x

. /usr/share/coreos/release
BUILD_TAG=coreos.zfs-builder.${COREOS_RELEASE_BOARD}-${COREOS_RELEASE_VERSION}
cd "$(dirname "$0")"
build_dir=build-${BUILD_TAG}


mkdir_build() {
  mkdir "$build_dir" ||true
}

download() {
    mkdir_build
    if [ -f /etc/coreos/update.conf ]; then
        . /etc/coreos/update.conf
        : ${COREOS_RELEASE_CHANNEL:=${GROUP}}
    else
        : ${COREOS_RELEASE_CHANNEL:=stable}
    fi
    if [ ! -f "$build_dir/coreos_developer_container.bin.bz2" ]; then
        curl -o "$build_dir/coreos_developer_container.bin.bz2" http://${COREOS_RELEASE_CHANNEL}.release.core-os.net/${COREOS_RELEASE_BOARD}/${COREOS_RELEASE_VERSION}/coreos_developer_container.bin.bz2
    fi
}

build() {
  download
  cat > "$build_dir"/Dockerfile <<EOF
FROM busybox
MAINTAINER STI-IT Dev <stiitdev@groupes.epfl.ch>

ADD coreos_developer_container.bin.bz2 /
# RUN bzcat /coreos_developer_container.bin.bz2 | tar -xf - -C /
EOF

  docker build -t epflsti/${BUILD_TAG} "$build_dir"
}

interactive() {
  docker rm -f ${BUILD_TAG} 2>/dev/null || true
  docker run -it \
         --name ${BUILD_TAG} \
         -v /usr/share/coreos:/host/usr/share/coreos \
         epflsti/${BUILD_TAG} /bin/sh
}

eval "$@"

