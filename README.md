# #! Shell Server #

<https://github.com/hashbang/shell-server>

## About ##

This repo contains the basic setup for a #! multi-user shell server,
pulling data from several locations:
- `/etc` is managed with [etckeeper], and kept in [shell-etc].
- whenever a user's homedir is created, it is populated with
  the contents of the (signed) [dotfiles] repository.

## Building ##

  Build/publish all image types:
  ```make all```

## Usage ##

Generally you want to use our pre-built images as follows.

### Docker ###
  ```
  docker run \
    -ti \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -p 2222:22 \
    --stop-signal SIGRTMIN+3 \
    --cap-add=SYS_ADMIN \
    --cap-add SYS_RESOURCE \
    --entrypoint "/sbin/init" \
    hashbang/shell-server:latest
  ```

[etckeeper]: http://etckeeper.branchable.com/
[shell-etc]: https://github.com/hashbang/shell-etc/
[dotfiles]:  https://github.com/hashbang/dotfiles/
