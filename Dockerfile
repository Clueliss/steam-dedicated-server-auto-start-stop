FROM centos/systemd

ENV PATH="/root/.cargo/bin:${PATH}"

EXPOSE 25565/tcp
EXPOSE 25565/udp

VOLUME ["/opt/mcserv", "/sys/fs/cgroup", "/tmp", "/run"]

COPY scripts/* /usr/local/bin/
COPY systemd-units/* /etc/systemd/system/

RUN chmod +x /usr/local/bin/mcserv-*
RUN yum install java-1.8.0-openjdk-headless curl git -y

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rustup.sh && \
    sh /tmp/rustup.sh -y --default-toolchain=nightly

RUN cd /tmp && \
    git clone https://github.com/Clueliss/systemd-query-rest && \
    cd systemd-query-rest && \
    bash ./install.sh

RUN systemctl enable mcserv.socket && systemctl enable systemd-query-rest.service

CMD ["/usr/sbin/init"]
