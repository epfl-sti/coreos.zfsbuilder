#!/bin/bash
#
# Build the kernel sources prepared by checkout-zfs.sh
#
# https://gitlab.epfl.ch/sti-it/ops.nemesis/issues/1
set -e -x

source "$(dirname "$0")"/zfslib.sh

sync_repo_to_manifest_version() {
    local repo_name="$1"
    (cd /coreos/src/third_party/"$repo_name"; git checkout  $(perl -ne 'm|name="coreos/'"$repo_name"'".*revision=".*/(.*?)"| && print $1' /coreos/.repo/manifests/build-${DISTRIB_RELEASE_MAJOR}.xml))
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

setup_zfs_sources() {
    (cd /usr/src; git clone https://github.com/zfsonlinux/zfs.git)
    local ZFS_VERSION="$(perl -ne 'm/Version:\s+(.*?$)/ && print $1' /usr/src/zfs/META)"
    (cd /usr/src/zfs; git checkout remotes/origin/zfs-"$ZFS_VERSION"-release)
    (cd /usr/src; git clone https://github.com/zfsonlinux/spl.git; ln -sf spl spl-"$ZFS_VERSION")
    (cd /usr/src/spl; git checkout remotes/origin/spl-"$ZFS_VERSION"-release)
}

setup_environment
setup_coreos_overlay
setup_zfs_sources
emerge sys-kernel/coreos-sources
