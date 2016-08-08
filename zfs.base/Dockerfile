FROM gentoo/stage3-amd64:latest
MAINTAINER STI-IT Dev <stiitdev@groupes.epfl.ch>

# Embed /usr/portage (as opposed to mounting it as a volume)
# From https://hub.docker.com/r/tharvik/gentoo-portage/~/dockerfile/
RUN emerge-webrsync
RUN eselect news read

# Some configuration
RUN echo 'EMERGE_DEFAULT_OPTS="--ask=n --jobs=2"' >> /etc/portage/make.conf
RUN echo 'FEATURES="unknown-features-warn parallel-fetch parallel-install"' >> /etc/portage/make.conf
RUN mkdir /etc/portage/env
RUN echo 'FEATURES="test"' > /etc/portage/env/test

# Fix silly error about missing Makefile.in
RUN perl -i -pe 's/elibtoolize/eautoreconf; elibtoolize/' /usr/portage/dev-libs/pth/pth-2.0.7-r3.ebuild

RUN emerge dev-vcs/git

ADD https://storage.googleapis.com/git-repo-downloads/repo /bin/repo
RUN chmod a+x /bin/repo
# Repo doesn't like Python 3:
RUN perl -i -pe 's{#!/usr/bin/env python}{#!/usr/bin/python2.7} if $. == 1' /bin/repo

# Muffle some spurious warnings from repo:
RUN git config --global user.email "stiitdev@groupes.epfl.ch"
RUN git config --global user.name "STI-IT Dev"

# Yes-man "tar" to work around https://github.com/coreos/bugs/issues/1095
RUN mv /bin/tar /bin/tar.ORIG
RUN echo "#!/bin/sh" > /bin/tar
RUN echo exec /bin/tar.ORIG '"$@"' >> /bin/tar
RUN chmod 755 /bin/tar

# Build ZFS userland – Unfortunately they cannot be installed, lest
# we have to rebuild the entire kernel support chain (dracut etc) first
# https://wiki.gentoo.org/wiki/ZFS
RUN echo "sys-fs/zfs ~amd64" >> /etc/portage/package.accept_keywords
RUN emerge awk  # Dependencies need to be installed before emerge -B
RUN emerge -B sys-fs/zfs
# Binary package found at or near /usr/portage/packages/sys-fs/zfs-0.6.5.4-r2.tbz2

# Prepare for further customization at build time
RUN mkdir /host
ONBUILD ADD lsb-release /host/
RUN mkdir /scripts
COPY checkout-zfs.sh zfslib.sh /scripts/
RUN chmod 755 /scripts/*.sh
ONBUILD RUN /scripts/checkout-zfs.sh
# TODO: merge in ../zfs/Dockerfile once it is tested.
# ONBUILD RUN /scripts/build-zfs.sh
