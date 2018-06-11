# #! Shell Server #

<https://github.com/hashbang/shell-server>

## About ##

This repo contains the basic setup for a #! multi-user shell server,
pulling data from several locations:
- `/etc` is managed with [etckeeper], and kept in [shell-etc].
- whenever a user's homedir is created, it is populated with
  the contents of the (signed) [dotfiles] repository.

## Building ##

You will normally need a #! account to use these, as they authenticate users
against our NSS services by default.

### Docker ###

#### Build image ####
```
make docker
```

#### Import image ####
```
gunzip -c dist/docker-20*.tar.gz | docker import - hashbang/shell-server:local-latest
```

#### Start container ####
```
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
```
ssh -p2222 your-hashbang-user@localhost
```

#### Root shell ####
```
docker exec -it shell-server bash
```

### LXC ###

#### Build image ####
```
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
```
make vagrant
```

#### Start server ####
```
vagrant init hashbang/shell-server
vagrant up
```

#### User shell ####
```
ssh -p2222 your-hashbang-user@localhost
```

#### Root shell ####
```
vagrant ssh
```

### Libvirt ###

#### Build Image ####
```
make qemu
```

#### Start server ####

```
virt-install \
  --name shell-server \
  --os-type linux \
  --os-variant debian9 \
  --ram 512 \
  --vcpus 2 \
  --disk path=dist/qemu-latest.qcow2 \
  --network user \
  --noautoconsole \
  --import \
  --force
```

#### User shell ####
```
virsh --connect qemu+ssh://username@shell-server/system
```

#### Root shell ####
```
TODO
```

### Qemu ###

#### Build Image ####
```
make qemu
```

#### Start server ####

```
qemu-system-x86_64 \
  -m 512M \
  -machine type=pc,accel=kvm \
  -net nic -net user,hostfwd=tcp::2222-:22 \
  -drive format=qcow2,file=dist/qemu-latest.qcow2
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
```
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
```
ansible-playbook -u root -i "target-server.com," ansible/main.yml
```

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
