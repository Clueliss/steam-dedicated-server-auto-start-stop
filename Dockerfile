FROM centos/systemd

EXPOSE 25565/tcp
EXPOSE 25565/udp

VOLUME ["/opt/mcserv", "/sys/fs/cgroup", "/tmp", "/run"]

COPY scripts/* /usr/local/bin/
COPY systemd-units/* /etc/systemd/system/

RUN chmod +x /usr/local/bin/mcserv-*
RUN yum install java-1.8.0-openjdk-headless -y
RUN systemctl enable mcserv.socket

CMD ["/usr/sbin/init"]
