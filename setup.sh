#!/bin/bash
[ -n "$DEBUG" ] && set -x
set -e
set -u
set -o pipefail

[ -f /.dockerenv ] && DOCKER=true

# Make apt-get be fully non-interactive
export DEBIAN_FRONTEND=noninteractive
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Turn on logging to disk
mkdir -p /var/log/journal
systemd-tmpfiles --create --prefix /var/log/journal
pgrep "systemd-journal" && pkill -USR1 systemd-journal # use 'journalctl --flush' once available

# Full system update/upgrade according to shell-etc settings
apt-get update
apt-get install -y -q --force-yes apt-transport-https curl apt-utils git

# Get isolated shell-etc repo if not already present
if [[ ! -d "/etc-git" ]]; then
	git clone https://github.com/hashbang/shell-etc.git /etc-git
fi

# Copy in apt preferences
cp /etc-git/apt/preferences /etc/apt/preferences
cp /etc-git/apt/sources.list /etc/apt/sources.list

# Set fastest apt mirror from httpredir but don't use directly.
apt_mirror=$( \
	curl -s -D - http://httpredir.debian.org/demo/debian/ | \
	awk '/^Link:/ { print $2 }' | \
	sed -e 's@<http://\(.*\)/debian/>;@\1@g' \
)
sed -i "s/httpredir.debian.org/$apt_mirror/" /etc/apt/sources.list

apt-get update
apt-cache dumpavail | dpkg --update-avail
dpkg --clear-selections
dpkg --set-selections < /etc-git/packages.txt
apt-get dselect-upgrade -q -y
apt-get upgrade
aptitude purge -y -q ~c

# Use msmtp as sendmail(1) implementation, Postfix's is silly
dpkg-divert /usr/sbin/sendmail
ln -sf /usr/bin/msmtp /usr/sbin/sendmail

# Point etckeeper at shell-etc repo and sync all configs
cd /etc
rm -rf .git
git init
git remote add origin https://github.com/hashbang/shell-etc.git
git fetch origin master
git reset --hard origin/master
git clean -d -f
etckeeper init # Apply the correct file permissions

# If running inside docker container, exit now
[ $? -eq 0 ] && [ -f /.dockerenv ] && exit 0

# Take /etc/default/grub into account
update-grub

# Disable users knowing about other users
for f in /var/run/utmp /var/log/wtmp /var/log/lastlog; do
    chmod 0660 "$f"               # Not readable by default users
    setfacl -m 'group:adm:r' "$f" # Readable by the adm group
done

reboot
