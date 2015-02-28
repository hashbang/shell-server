#!/bin/bash
# Convert Stock Debian 7 system to #! shell server

SHELL_SOURCES=/root/Sources/shell-server

printf "\n\n ---- Cloning #! Shell-Server Repo  ---- \n\n"
apt-get install -y git
rm -rf $SHELL_SOURCES
mkdir -p $SHELL_SOURCES
git clone https://github.com/hashbang/shell-server $SHELL_SOURCES

printf "\n\n ---- Updating To Jessie  ---- \n\n"
cp $SHELL_SOURCES/etc/apt/sources.list /etc/apt/sources.list
echo "force-confold" >> /etc/dpkg/dpkg.cfg
echo "force-confdef" >> /etc/dpkg/dpkg.cfg
DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get update -y -q --force-yes
DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get upgrade -y -q --force-yes
DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get dist-upgrade -y -q --force-yes

printf "\n\n ---- Cleaning Up  ---- \n\n"
apt-get autoremove -y -q --force-yes

exit 0

printf "\n\n ---- Installing Packages  ---- \n\n"
# Note: Do not add anything that requires X11 to
# this list or lrvick will murder you in the face.
apt-get install \
build-essential \
perl \
python \
ruby \
finger \
mktemp \
luarocks \
lua5.1 \
lua5.2 \
lua5.2-dev \
luajit \
golang \
nodejs \
nodejs-legacy \
npm \
sbcl \
ghc \
gcc \
smlnj \
vim \
nano \
joe \
alpine-pico \
e3 \
ne \
zile \
mg \
jed \
encfs \
gnupg \
ccrypt \
calcurse \
remind \
wyrd \
tudu \
bash \
zsh \
fish \
ksh \
mutt \
alpine \
slrn \
offlineimap \
mailutils \
ledger \
qalc \
weechat-curses \
irssi \
centerim \
bitlbee \
barnowl \
pork \
scrollz \
ii \
sic \
erc \
newsbeuter \
rsstail \
canto \
rawdog \
links \
elinks \
lynx \
w3m \
html2text \
sqlite3 \
mysql-server \
postgresql \
mongodb \
redis-server \
mc \
rsync \
rsyncrypto \
duplicity \
vifm \
ranger \
ncdu \
locate \
tree \
atool \
zip \
unzip \
p7zip \
dar \
zpaq \
iptraf \
nethogs \
slurm \
ngrep \
tcpdump \
trickle \
ifstat \
iftop \
mtr \
telnet \
netpipes  \
ssh \
siege \
lftp \
curl \
rtorrent \
aria2 \
ipcalc \
socat \
netcat \
rabbitmq-server \
optipng \
libgd-tools \
cvs \
subversion \
mercurial \
git \
tig \
cloc \
diffutils \
ctags \
cmake \
nethack-console \
slashem \
cmatrix \
frotz \
bsdgames \
bb \
sl \
bastet \
greed \
gnugo \
gnuchess \
moon-buggy \
typespeed \
tf \
tintin++ \
pennmush \
bonnie++ \
htop \
dstat \
iotop \
sysdig \
strace \
cpulimit \
cgroup-bin \
tmux \
screen \
dtach \
byobu \
pv \
ttyrec \
parallel \
ack \
c-repl \
watch \
libev-dev \
libevent-dev \
lame \
cowsay \
dos2unix

# Copy over configs from repo
rsync -Pav $SHELL_SOURCES/ /
