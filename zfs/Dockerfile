FROM registry.service.consul:5000/cluster.coreos.zfs.base

# TODO: Once it works, move these lines to ../zfs.base/Dockerfile as ONBUILDs
RUN (zcat /proc/config.gz; \
 echo CONFIG_SPL=m; \
 echo CONFIG_ZFS=m; ) > /usr/src/linux/.config
RUN make -C/usr/src/linux silentoldconfig modules_prepare
