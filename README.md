# #! Shell Server #

<https://github.com/hashbang/shell-server>

## About ##

This repo contains the basic setup for a #! multi-user shell server,
pulling data from several locations:
- `/etc` is managed with [etckeeper], and kept in [shell-etc].
- whenever a user's homedir is created, it is populated with
  the contents of the (signed) [dotfiles] repository.

## Building ##

Build all image types:

```
make all
```

Or build a specific image type such as vagrant:
```
make vagrant
```

All artifacts will be placed in `$PWD/dist`.

## Releasing ##

1. Copy config sample and populate with your credentials as desired:

    ```
    cp config.sample.json config.json
    vim config.json
    ```

2. Build, sign, and publish all image types
    ```
    make build release
    ```
## Development ##

Generally you want to use our pre-built images.

The following will get you a standalone shell-server locally to develop on.

You will need a #! account to use these, as they authenticate users against
our NSS services by default.

These are intended to mirror the flow of you setting up a federated server as
per the [Deployment] section of this Readme.

For completely self-hosted development infrastructure consider the e2e
testing/development suite found in the [hashbang] repo.

### Docker ###

Start server:
```
docker run \
  -it \
  --name shell-server \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -p 2222:22 \
  --stop-signal SIGRTMIN+3 \
  --cap-add SYS_ADMIN \
  --cap-add SYS_RESOURCE \
  hashbang/shell-server:latest \
  /sbin/init
```

Root shell:
```
docker exec -it shell-server bash
```

User shell:
```
ssh -p2222 your-hashbang-user@localhost
```

### Vagrant ###

Start server:
```
vagrant init hashbang/shell-server
vagrant up
```

Root shell:
```
vagrant ssh
```

User shell:
```
ssh -p2222 your-hashbang-user@localhost
```

### Libvirt/KVM ###

Download Image:
```
wget https://builds.hashbang.sh/shell-server/qemu-latest.qcow2
```

Start server:
```
virt-install \
  --name shell-server \
  --os-type linux \
  --ram 512 \
  --vcpus 2 \
  --disk path=qemu-latest.qcow2 \
  --network network:default \
  --noautoconsole \
  --import \
  --force
```

Root shell:
```
TBD
```

User shell:
```
virsh --connect qemu+ssh://username@shell-server/system
```

### LXC ###
TBD

## Deployment ##
### Amazon ###
TBD

### DigitalOcean ###
TBD

### Bare Metal ###
To set this up on a live server, perform the following:

1. Adjust partitions to match [fstab.sample]

    Typically you would specify a secondary drive for /home when you provision
    your server allowing you to use fstab.sample almost as-is.

    Sometimes that is not an option.

    To reprovision a single disk live system consider these steps:

    1. Go to the "Virtual Console" feature in your provider.
    2. Reboot to Grub bootloader screen
    3. Hit <Enter> on first boot option
    4. Add ```break=premount``` to the end of the kernel line
    5. <Ctrl-X> to boot
    6. Copy rootfs files into ram
      ```
      mkdir /mnt
      modprobe ext4
      mount /dev/sda1 /mnt
      cp -R /mnt/* /
      umount /dev/sda1
      ```
    7. Shrink rootfs and create /home partition
      ```
      e2fsck -f /dev/sda1
      resize2fs /dev/sda1 20G
      echo "d
      1
      n
      p
      1

      +20G
      w
      n
      p
      2


      " | fdisk /dev/sda1
      ```
    8. Reboot
    9. Adjust fstab to match: [fstab.sample]
    10. Reboot

2. Run setup script

    ```bash
    ssh $INSTANCE_IP
    wget https://raw.githubusercontent.com/hashbang/shell-server/master/scripts/setup.sh
    bash setup.sh
    ```
[Deployment]: #deployment
[etckeeper]: http://etckeeper.branchable.com/
[hashbang]: http://github.com/hashbang/hashbang/
[shell-etc]: https://github.com/hashbang/shell-etc/
[dotfiles]:  https://github.com/hashbang/dotfiles/
[fstab.sample]: https://raw.githubusercontent.com/hashbang/shell-etc/master/fstab.sample
