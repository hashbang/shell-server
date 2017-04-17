#!/bin/sh -ex
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

die() {
    echo "$@" >&2
    exit 1
}

# Some basic assumptions
[ -d /etc-git/.git ]              || die "/etc-git is not a git repo, something has gone wrong"
[ -f /usr/lib/apt/methods/https ] || die "Please install apt-transport-https"
command -v etckeeper >/dev/null   || die "Please install etckeeper"

# Apply the new config
# It is done this way to avoid removing things that are in .gitignore
rm -rf /etc/.git
rsync -aAX /etc-git/ /etc/
rm -rf /etc-git
git -C /etc clean -df

# Restore correct permissions in /etc
# This requires having the correct /etc/passwd and /etc/group,
# which should be in /etc-git.
etckeeper init

# Turn on logging to disk
#mkdir -p /var/log/journal
#systemd-tmpfiles --create --prefix /var/log/journal
#pkill -USR1 systemd-journal || true # use 'journalctl --flush' once available

# Update the apt and dpkg caches
apt-get update
apt-cache dumpavail | dpkg --update-avail

# Set dpkg selections
dpkg --clear-selections
dpkg --set-selections < /etc/packages.txt

# Fix some things that maintainer scripts expect
mkdir -p /var/lib/bitlbee
mkdir -p /usr/local/lib/luarocks/rocks-5.1 #WTF is that even needed?

# Install packages, keep the configuration from git
export DEBIAN_FRONTEND=noninteractive
export ETCKEEPER_NO_PUSH=1
apt-get dselect-upgrade -o Dpkg::Options::="--force-confold" -q -y
apt-get upgrade

# Purge uninstalled packages and the package cache
aptitude purge -y -q ~c
apt-get clean

# Use msmtp as sendmail(1) implementation, Postfix's is silly
dpkg-divert /usr/sbin/sendmail
ln -sf /usr/bin/msmtp /usr/sbin/sendmail

# Disable users knowing about other users
for f in /var/run/utmp /var/log/wtmp /var/log/lastlog; do
    chmod 0660 "$f"               # Not readable by default users
    setfacl -m 'group:adm:r' "$f" # Readable by the adm group
done

# If running inside a docker container, exit now
if [ -f /.dockerenv ]; then
    exit 0
fi

# Take /etc/default/grub into account
#update-grub
