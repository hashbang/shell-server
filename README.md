# #! Shell Server #

<https://github.com/hashbang/shell-server>

## About ##

This repo contains the basic setup for a #! multi-user shell server,
pulling data from several locations:
- `/etc` is managed with [etckeeper], and kept in [shell-etc].
- whenever a user's homedir is created, it is populated with
  the contents of the (signed) [dotfiles] repository.

[etckeeper]: http://etckeeper.branchable.com/
[shell-etc]: https://github.com/hashbang/shell-etc/
[dotfiles]:  https://github.com/hashbang/dotfiles/
