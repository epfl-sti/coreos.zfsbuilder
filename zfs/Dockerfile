FROM registry.service.consul:5000/cluster.coreos.zfs.base

RUN zcat /proc/config.gz > /usr/src/linux/.config
RUN make -C/usr/src/linux prepare scripts
RUN set -e -x; cd /usr/src/spl; ./autogen.sh; ./configure --enable-linux-builtin; ./copy-builtin /usr/src/linux
RUN set -e -x; cd /usr/src/zfs; ./autogen.sh; ./configure --enable-linux-builtin; ./copy-builtin /usr/src/linux
RUN (echo CONFIG_SPL=m; echo CONFIG_ZFS=m ) >> /usr/src/linux/.config
WORKDIR /usr/src/linux
RUN make silentoldconfig modules_prepare
RUN make modules M="spl"
RUN make modules M="fs/zfs"
RUN cat fs/zfs/modules.order spl/modules.order > modules.order
RUN touch modules.builtin
RUN make modules_install M="spl"
RUN make modules_install M="fs/zfs"
WORKDIR /
RUN depmod -a

