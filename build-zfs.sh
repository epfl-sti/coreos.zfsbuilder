#!/bin/bash
#
# https://gitlab.epfl.ch/sti-it/ops.nemesis/issues/1
set -e -x


download_kernel_sources() {
    . /host/usr/share/coreos/lsb-release
    # From https://coreos.com/os/docs/latest/sdk-modifying-coreos.html:
    mkdir /coreos
    
    # "| cat" prevents color autodetect monkey business
    (cd /coreos; repo init -u https://github.com/coreos/manifest.git -b refs/tags/v${DISTRIB_RELEASE}) |cat
    (cd /coreos; repo sync coreos/coreos-overlay)
    # This syncs to the latest version; need to roll back to the version
    # recorded build-${COREOS_BUILD}.xml:
    . /coreos/.repo/manifests/version.txt
    OVERLAY_GIT_VERSION=$(perl -ne 'm|name="coreos/coreos-overlay".*revision="(.*?)"| && print $1' /coreos/.repo/manifests/build-${COREOS_BUILD}.xml)
    (cd /coreos/src/third_party/coreos-overlay; git checkout ${OVERLAY_GIT_VERSION})
    return  # XXX

    KERNEL_RELEASE_MINOR=$(uname -r | cut -d. -f1-2)

    git clone -b build-${DISTRIB_RELEASE_MAJOR} https://github.com/coreos/coreos-overlay.git
}

patch_kernel() {
    :
}

configure_kernel() {
    :
}

build_zfs_sources() {
    :
}

download_kernel_sources
