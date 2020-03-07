# #! Shell Server #

<https://github.com/hashbang/shell-server>

## About ##

This is the central build and management repository for #! shell servers.

It should contain everything required to run your own #! shell server, or to
develop changes to be deployed to all existing deployed servers.

Existing servers automatically update from this repo via ansible-pull.

## Requirements ##

  | Tool       | Version | Needed for Builder   |
  | ---------- | ------- | -------------------- |
  | Ansible    | v2.5+   | all                  |
  | Packer     | v1.3x+  | all                  |
  | Docker     | v18.0+  | Docker               |
  | qemu       | v2.12+  | qemu, libvirt        |
  | Virtualbox | v5.2+   | virtualbox, vagrant  |
  | Vagrant    | v2.1.1+ | vagrant              |
  | Linux      | v4.16+  | lxc, libvirt         |
  | lxc        | v3.0+   | lxc                  |

## Building ##

You will normally need a #! account to use these, as they authenticate users
against our NSS services by default.

### Docker ###

#### Build image ####
```sh
make docker
```

#### Import image ####
```sh
docker import .packer/build/docker/docker.tar hashbang/shell-server:local-latest
```

#### Start container ####
```sh
docker run \
  -it \
  --rm \
  --name shell-server \
  -p 8080:80 \
  -p 4443:443 \
  -p 2222:22 \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --stop-signal SIGRTMIN+3 \
  --cap-add SYS_ADMIN \
  --cap-add SYS_RESOURCE \
  --security-opt apparmor=unconfined \
  --security-opt seccomp=unconfined \
  hashbang/shell-server:local-latest \
  /lib/systemd/systemd
```

#### User shell ####
```sh
ssh -p2222 your-hashbang-user@localhost
```

#### Root shell ####
```sh
docker exec -it shell-server bash
```

### LXC ###

#### Build image ####
```sh
make lxc
```

#### User shell ####
```
TODO
```

#### Root shell ####
```
TODO
```

### Vagrant ###

#### Build Image ####
```sh
make vagrant
```

#### Start server ####
```sh
vagrant init hashbang/shell-server
vagrant up
```

#### User shell ####
```sh
ssh -p2222 your-hashbang-user@localhost
```

#### Root shell ####
```sh
vagrant ssh
```

### Libvirt ###

#### Build Image ####
```sh
make qemu
```

#### Start server ####

```sh
virt-install \
  --name shell-server \
  --os-type linux \
  --os-variant debian9 \
  --ram 512 \
  --vcpus 2 \
  --disk path=.packer/build/qemu/packer-qemu \  # no file extension
  --network user \
  --noautoconsole \
  --import \
  --force
```

#### User shell ####
```sh
virsh --connect qemu+ssh://username@shell-server/system
```

#### Root shell ####
```
TODO
```

### Qemu ###

#### Build Image ####
```sh
make qemu
```

#### Start server ####

```
qemu-system-x86_64 \
  -m 512M \
  -machine type=pc,accel=kvm \
  -net nic -net user,hostfwd=tcp::2222-:22 \
  -drive format=qcow2,file=.packer/build/qemu/packer-qemu  # no file extension
```

#### User shell ####

```
TODO
```

#### Root shell ####

```
TODO
```

## Development ##

Once you have root access on a development debian server be it local or remote,
you can test your locally made ansible playbook changes as follows.

### Run Ansible Playbook
```sh
ansible-playbook \
  -u root \
  -i "localhost," \
  -e ansible_ssh_port=2222 \
  ansible/main.yml
```

## Deployment ##

### Kubernetes ###
TODO

### Amazon ###
TODO

### DigitalOcean ###
TODO

### Google Cloud ###
TODO

### Azure ###
TODO

### Bare Metal ###
```sh
ansible-playbook -u root -i "target-server.com," ansible/main.yml
```

## Releasing ##

1. Copy config sample and populate with your credentials as desired:

    ```sh
    cp config.sample.json config.json
    vim config.json
    ```

2. Build, sign, and publish all image types
    ```sh
    make build release
    ```
