# #! Shell Server #

<https://github.com/hashbang/shell-server>

## About ##

This repo represents the basic setup for a #! multi-user shell server.

Files in the /etc path are managed via [etckeeper](http://etckeeper.branchable.com/).

Our etckeeper repo can be found here: [shell-etc](https://github.com/hashbang/shell-etc)

The default configuration for new users can be found here: [dotfiles](https://github.com/hashbang/dotfiles)

## Setup ##

### Local Docker ###

```bash
docker run -d hashbang/shell-server
```

### Bare-metal ###

To set this up on a live server, perform the following:

1. Adjust partitions to match fstab.sample

    To do this on a VPS (Super hacky but works):
    
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

    9. Adjust fstab to match: [fstab.sample](https://raw.githubusercontent.com/hashbang/shell-server/master/fstab.sample)

    10. Reboot

2. Run setup script

    ```bash
    ssh $INSTANCE_IP
    wget https://raw.githubusercontent.com/hashbang/hashbang/master/shellbox/setup.sh
    bash setup.sh
    ```

## Building ##

### Docker Image ###

```
docker build -t hashbang/shell-server .
```

### Amazon AMI ###

TODO
