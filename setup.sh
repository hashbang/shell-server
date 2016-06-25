#!/bin/bash
[ -n "$DEBUG" ] && set -x
set -e
set -u
set -o pipefail

[ -f /.dockerenv ] && DOCKER=true

# Make apt-get be fully non-interactive
export DEBIAN_FRONTEND=noninteractive
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

function retry() {
  tries=$1
  interval=$2
  expected_exit_code=$3
  shift 3

  while [ "$tries" -gt 0 ]; do
    $@
    last_exit_code=$?

    if [ "$last_exit_code" -eq "$expected_exit_code" ]; then
      break
    fi

    tries=$((tries-1))
    if [ "$tries" -gt 0 ]; then
      sleep $interval
    fi
  done
  # Ugly hack to avoid substitution (re_turn -> exit)
  "re""turn" $last_exit_code
}

function retry_apt_get() {
  retry 5 5 0 apt-get -o APT::Acquire::Retries=5 $@
}

# Turn on logging to disk
mkdir -p /var/log/journal
systemd-tmpfiles --create --prefix /var/log/journal
pgrep "systemd-journal" && pkill -USR1 systemd-journal # use 'journalctl --flush' once available

# Full system update/upgrade according to shell-etc settings
retry_apt_get update
retry_apt_get install -y -q --force-yes apt-transport-https curl apt-utils git

git clone https://github.com/hashbang/shell-etc.git /etc-git

cp /etc-git/apt/preferences /etc/apt/preferences
cp /etc-git/apt/sources.list /etc/apt/sources.list

# Set fastest apt mirror as httpredir is unstable with large pulls
apt_mirror=$( \
	curl -s -D - http://httpredir.debian.org/demo/debian/ | \
	awk '/^Link:/ { print $2 }' | \
	sed -e 's@<http://\(.*\)/debian/>;@\1@g' \
)
sed -i "s/httpredir.debian.org/$apt_mirror/" /etc/apt/sources.list

retry_apt_get update
apt-cache dumpavail | dpkg --update-avail
dpkg --clear-selections
dpkg --set-selections < /etc-git/packages.txt
retry_apt_get dselect-upgrade -q -y
retry_apt_get upgrade
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
