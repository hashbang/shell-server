# #! Shell Server #

<https://github.com/hashbang/shell-server>

## About ##

This repo contains the basic setup for a #! multi-user shell server,
pulling data from several locations:
- `/etc` is managed with [etckeeper], and kept in [shell-etc].
- whenever a user's homedir is created, it is populated with
  the contents of the (signed) [dotfiles] repository.

## Building ##

  Build all image types
  ```
  make all
  ```

## Publishing ##

  1. Copy config sample and populate with your credentials as desired:
    ```
    cp packer.cfg.sample packer.cfg
    vim packer.cfg
    ```

  2. Build all image types
    ```
    make publish
    ```
## Development ##

Generally you want to use our pre-built images.

The following will get you a standalone shell-server locally to develop on.

You will need a #! account to use these, as they authenticate users against
our NSS services by default.

These are intended to mirror the flow of you setting up a federated server as
per the Deployment section of this Readme.

For a -fully- local development infrastructure consider the e2e
testing/development suite found in the [hashbang] repo.

### Docker ###

  Start server:
  ```
  docker run \
    -ti \
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

### Qemu ###

  Download Image:
  ```
  wget https://builds.hashbang.sh/shell-server/qemu-latest.qcow2
  ```

  Start server:
  ```
  ```

  Root shell:
  ```
  ```

  User shell:
  ```
  ```

### LXC ###
TBD

## Deployment ##
### Amazon ###
TBD

### DigitalOcean ###
TBD

### Bare Meal ###
TBD

## Design ##


The only supported Deployment methods at this time are

[etckeeper]: http://etckeeper.branchable.com/
[hashbang]: http://github.com/hashbang/hashbang/
[shell-etc]: https://github.com/hashbang/shell-etc/
[dotfiles]:  https://github.com/hashbang/dotfiles/
