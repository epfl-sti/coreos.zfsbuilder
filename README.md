# ZFS on CoreOS


## How To

1. Download the CoreOS Developer Container (CDC): `./build.sh build`

1. Bunzip the CDC, e.g.: `bunzip2 build-coreos.zfs-builder.amd64-usr-928.0.0/coreos_developer_container.bin.bz2`
1. Launch the CoreOS developer container, e.g.:
  `sudo systemd-nspawn --cap=CAP_SYS_MODULE -i build-coreos.zfs-builder.amd64-usr-928.0.0/coreos_developer_container.bin --share-system`
  (Instructions from https://gist.github.com/marineam/9914debc25c8d7dc458f)

1. `cd /`

1. `emerge-gitclone`

1. `emerge -gKav coreos-sources`
    * Unable to enable loopback interface: EPERM
    * Would you like to merge these packages? [Yes/No] Yes

1. `cd /usr/src/linux`

1. `zcat /proc/config.gz >.config`

1. `make modules_prepare`

1. Install 'spl': `wget http://archive.zfsonlinux.org/downloads/zfsonlinux/spl/spl-0.6.5.5.tar.gz`

1. `tar zxvf spl-0.6.5.5.tar.gz && cd spl-0.6.5.5`

1. `./configure`

1. `make` => Solaris Porting Layer Linux Kernel Module done: **spl.ko**

1. `make install`

1. `ldconfig`

1. Install ZFS: `wget http://archive.zfsonlinux.org/downloads/zfsonlinux/zfs/zfs-0.6.5.5.tar.gz`

1. `tar zxvf zfs-0.6.5.5.tar.gz && cd zfs-0.6.5.5`

1. `./configure --with-spl=$PWD/../spl-0.6.5.5/`

1. `make`

1. `make install`

1. `ldconfig`

1. `zfs` is working but no Kernel module are loaded


## ToDo
1. Copy `*.ko` to the host:
    * /lib/module/4.4.0-coreos/extra/zfs/zfs.ko
    * /lib/module/4.4.0-coreos/extra/spl/spl.ko
    * /lib/module/4.4.0-coreos/extra/zcommon/zcommon.ko

1. To test in the nspawn container: `modprobe zfs`

1. `mkdir /var/zfs`

1. `fallocate -l 10G /var/zfs/tank0000`

1. `zpool create tank /var/zfs/tank0000`

1. `zpool list`
