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

RUN wget -O /bin/repo https://storage.googleapis.com/git-repo-downloads/repo
RUN chmod a+x /bin/repo
# Repo doesn't like Python 3:
RUN perl -i -pe 's{#!/usr/bin/env python}{#!/usr/bin/python2.7} if $. == 1' /bin/repo

# repo complains if we don't do this:
RUN git config --global user.email "stiitdev@groupes.epfl.ch"
RUN git config --global user.name "STI-IT Dev"

# Yes-man "tar" to work around https://github.com/coreos/bugs/issues/1095
RUN mv /bin/tar /bin/tar.ORIG
RUN echo "#!/bin/sh" > /bin/tar
RUN echo exec /bin/tar.ORIG '"$@"' >> /bin/tar
RUN chmod 755 /bin/tar

COPY build-zfs.sh /build-zfs.sh
