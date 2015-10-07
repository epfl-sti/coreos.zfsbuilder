FROM gentoo/stage3-amd64:latest
MAINTAINER STI-IT Dev <stiitdev@groupes.epfl.ch>

# Embed /usr/portage (we only need git and emerge itself)
# From https://github.com/gentoo/gentoo-docker-images/blob/master/portage/Dockerfile
ADD http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2 /

RUN mkdir -p /usr
RUN bzcat /portage-latest.tar.bz2 | tar -xf - -C /usr
RUN mkdir -p /usr/portage/distfiles /usr/portage/metadata /usr/portage/packages

RUN emerge net-misc/curl

# From https://coreos.com/os/docs/latest/sdk-modifying-coreos.html
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /bin/repo
RUN chmod a+x /bin/repo
 
RUN emerge dev-vcs/git
 
# # repo complains if we don't do this:
# RUN git config --global user.email "stiitdev@groupes.epfl.ch"
# RUN git config --global user.name "STI-IT Dev"

COPY build-zfs.sh /build-zfs.sh
