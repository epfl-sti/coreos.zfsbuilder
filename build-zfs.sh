#!/bin/bash
#
# https://gitlab.epfl.ch/sti-it/ops.nemesis/issues/1
set -e -x

setup_environment() {
    KERNEL_RELEASE_MINOR=$(uname -r | cut -d. -f1-2)
    # Obtain $DISTRIB_RELEASE:
    . /host/usr/share/coreos/lsb-release
    DISTRIB_RELEASE_MAJOR=$(echo "${DISTRIB_RELEASE}" |cut -d. -f1)
}

sync_repo_to_manifest_version() {
    local repo_name="$1"
    (cd /coreos/src/third_party/"$repo_name"; git checkout  $(perl -ne 'm|name="coreos/'"$repo_name"'".*revision="(.*?)"| && print $1' /coreos/.repo/manifests/build-${DISTRIB_RELEASE_MAJOR}.xml))
}

setup_coreos_overlay() {
    # See https://coreos.com/os/docs/latest/sdk-modifying-coreos.html

    mkdir /coreos
    # "| cat" prevents color autodetect monkey business
    (cd /coreos; repo init -u https://github.com/coreos/manifest.git -b refs/tags/v${DISTRIB_RELEASE}) |cat
    (cd /coreos; repo sync coreos/portage-stable coreos/coreos-overlay)
    # The above synced to latest; roll back to version in manifest
    sync_repo_to_manifest_version portage-stable
    sync_repo_to_manifest_version coreos-overlay
    if ! grep postage-stable /usr/share/portage/config/repos.conf; then
      cat >> /usr/share/portage/config/repos.conf <<EOF
[portage-stable]
location = /coreos/src/third_party/portage-stable

[coreos]
location = /coreos/src/third_party/coreos-overlay

EOF
    fi
}

prepare_kernel() {
    emerge sys-kernel/coreos-sources
    zcat /proc/config.gz > /usr/src/linux/.config
    make -C/usr/src/linux silentoldconfig modules_prepare
}

build_zfs_sources() {
    :
}

setup_environment
setup_coreos_overlay
prepare_kernel
