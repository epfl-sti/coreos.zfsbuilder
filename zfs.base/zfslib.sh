#!/bin/bash
#
# https://gitlab.epfl.ch/sti-it/ops.nemesis/issues/1
set -e -x

setup_environment() {
    KERNEL_RELEASE_MINOR=$(uname -r | cut -d. -f1-2)
    # Obtain $DISTRIB_RELEASE:
    . /host/lsb-release
    DISTRIB_RELEASE_MAJOR=$(echo "${DISTRIB_RELEASE}" |cut -d. -f1)
}
