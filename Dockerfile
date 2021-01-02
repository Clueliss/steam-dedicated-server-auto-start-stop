FROM unop/fedora-systemd

EXPOSE 25565/tcp
EXPOSE 25565/udp

VOLUME ["/opt/mcserv", "/sys/fs/cgroup", "/tmp", "/run"]

COPY scripts/* /usr/local/bin
COPY systemd-units/* /etc/systemd/system

RUN chmod +x /usr/local/bin/mcserv-*

RUN dnf --refresh update -y
RUN dnf install java-1.8.0-openjdk-headless -y

CMD ["/usr/sbin/init"]
