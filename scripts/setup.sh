#!/bin/sh -ex
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive
export ETCKEEPER_NO_PUSH=1

die() {
    echo "$@" >&2
    exit 1
}

in_docker() {
    [ -f /.dockerenv ]
}

# Some basic assumptions
apt update
apt install -y apt-transport-https etckeeper

if [ -d /etc-git/ ]; then
    [ -d /etc-git/.git ] || die "/etc-git is not a git repo, something has gone wrong"
else
    # Assume we are pulling the current production branch
    git clone https://github.com/hashbang/shell-etc.git /etc-git
fi


# Fix some things that maintainer scripts expect
# Those should probably be filed as Debian bugs...
mkdir -p /var/lib/bitlbee
mkdir -p /usr/local/lib/luarocks/rocks-5.1 #WTF is that even needed?
apt install -y gawk # gawk is required for python2.7-minimal


# Make sure the root can git-commit
# This can happen when pkg updates result in conffile changes
git config --global user.name  "Enoch Root"
git config --global user.email "root@hashbang.sh"


# Deal with Docker quirks
if in_docker; then
    echo 'resolvconf resolvconf/linkify-resolvconf boolean false' | \
	debconf-set-selections
fi


# Apply the new config
# It is done this way to avoid removing things that are in .gitignore
rm -rf /etc/.git
rsync -aAX /etc-git/ /etc/
rm -rf /etc-git
git -C /etc clean -df

# Restore correct permissions in /etc
# This requires having the correct /etc/passwd and /etc/group,
# which got copied over in the previous step
etckeeper init

# Update the apt and dpkg caches
apt-get update
apt-cache dumpavail | dpkg --update-avail

# Set dpkg selections
dpkg --clear-selections
dpkg --set-selections < /etc/packages.txt

# Install packages, keep the configuration from git
apt-get dselect-upgrade -o Dpkg::Options::="--force-confold" -q -y --force-yes
apt-get upgrade

# Purge uninstalled packages and the package cache
aptitude purge -y -q '~c'
apt-get clean

# Use msmtp as sendmail(1) implementation, Postfix's is silly
dpkg-divert /usr/sbin/sendmail
ln -sf /usr/bin/msmtp /usr/sbin/sendmail

# Disable users knowing about other users
for f in /var/run/utmp /var/log/wtmp /var/log/lastlog; do
    chmod 0660 "$f"               # Not readable by default users
    setfacl -m 'group:adm:r' "$f" # Readable by the adm group
done

# Make docker-specific changes and exit
if in_docker; then
	cd /lib/systemd/system/sysinit.target.wants/
	ls | grep -v systemd-tmpfiles-setup.service | xargs rm -f
	rm -f /lib/systemd/system/sockets.target.wants/*udev*
	systemctl mask -- \
		tmp.mount \
		etc-hostname.mount \
		etc-hosts.mount \
		etc-resolv.conf.mount \
		-.mount \
		swap.target \
		getty.target \
		getty-static.service \
		dev-mqueue.mount \
		systemd-tmpfiles-setup-dev.service \
		systemd-remount-fs.service \
		systemd-ask-password-wall.path \
		systemd-logind.service && \
	systemctl set-default multi-user.target || true
	ln -s /lib/systemd/system/systemd-logind.service /etc/systemd/system/multi-user.target.wants/systemd-logind.service
	ln -s /lib/systemd/system/dbus.socket /etc/systemd/system/sockets.target.wants/dbus.socket
	sed -ri /etc/systemd/journald.conf -e 's!^#?Storage=.*!Storage=volatile!'
    echo 'ForwardToConsole=yes' >> /etc/systemd/journald.conf
    systemctl set-default multi-user.target
    systemctl enable ssh
    exit 0
fi

mkdir -p /var/log/journal
systemd-tmpfiles --create --prefix /var/log/journal
pkill -USR1 systemd-journal || true # use 'journalctl --flush' once available

# Take /etc/default/grub into account
if ! in_docker; then
    update-grub
fi

# Minimize the size of the disk image if fstrim is available
if [ -x /sbin/fstrim ]; then
   fstrim -av
fi
