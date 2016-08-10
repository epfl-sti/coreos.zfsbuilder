FROM registry.service.consul:5000/cluster.coreos.zfs.base

# TODO: Once it works, move these lines to ../zfs.base/Dockerfile as ONBUILDs
RUN zcat /proc/config.gz > /usr/src/linux/.config
RUN make -C/usr/src/linux prepare scripts
RUN set -e -x; cd /usr/src/spl; ./autogen.sh; ./configure --enable-linux-builtin; ./copy-builtin /usr/src/linux
RUN set -e -x; cd /usr/src/zfs; ./autogen.sh; ./configure --enable-linux-builtin; ./copy-builtin /usr/src/linux
RUN (echo CONFIG_SPL=m; echo CONFIG_ZFS=m ) >> /usr/src/linux/.config
RUN make -C/usr/src/linux silentoldconfig modules_prepare
RUN make -C/usr/src/linux modules SUBDIRS="spl"
RUN make -C/usr/src/linux modules SUBDIRS="fs/zfs"

