FROM debian:jessie

ENV container=docker \
    init="/lib/systemd/systemd" \
    HOME=/root \
    LC_ALL=C \
    DEBIAN_FRONTEND=noninteractive \
    DEBUG=true \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Ensure base image is up to date
RUN apt-get update && \
    apt-get install -y --force-yes wget ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# We must mount cgroup from host OS for systemd to function
VOLUME [ "/sys/fs/cgroup" ]

# Block apt-get writes to /etc/resolv.conf. It is maintained by Docker
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

# Remove systemd units that don't make sense in a container
RUN cd /lib/systemd/system/sysinit.target.wants/; \
    ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1 \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;

# Import external etc folder to ensure re-build on etc changes
ADD etc /etc-git

# Run our generic #! shellbox setup script
ADD setup.sh /
RUN bash /setup.sh

# Set upstream to /etc-git to allow for mounting host repo
RUN git --git-dir=/etc/.git --work-tree=/etc remote rm origin; \
    git --git-dir=/etc/.git --work-tree=/etc remote add origin /etc-git

# Configure journald to be visible on stdout and `docker logs`
RUN echo "ForwardToConsole=yes" >> /etc/systemd/journald.conf

RUN systemctl set-default multi-user.target
RUN systemctl enable ssh

# Allow incoming ports
EXPOSE 22

# Start systemd
ENTRYPOINT ["/lib/systemd/systemd"]
