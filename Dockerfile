FROM rustlang/rust:nightly-bullseye-slim AS builder
WORKDIR /usr/src/systemd-query-rest
COPY systemd-query-rest ./
RUN cargo build --release


FROM jrei/systemd-debian:11

VOLUME ["/opt/mcserv", "/sys/fs/cgroup", "/tmp", "/run", "/run/lock"]

EXPOSE 25565/tcp
EXPOSE 25565/udp
EXPOSE 8000/tcp

ENV MINECRAFT_UID=0
ENV MINECRAFT_GID=0
ENV MINECRAFT_PASSWORD=minecraft
ENV MINECRAFT_TIMEOUT=15min
ENV MINECRAFT_SERVER_JAR=
ENV MINECRAFT_JVM_ARGS=
ENV MINECRAFT_JAR_ARGS=

RUN apt-get update \
    && apt-get install openjdk-17-jre-headless vsftpd -y \
    && useradd --system --no-create-home --user-group --shell /sbin/nologin --home-dir /opt/mcserv minecraft \
    && echo '/sbin/nologin' >> /etc/shells \
    && sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf

COPY scripts/* /usr/local/bin/
COPY systemd-units/* /etc/systemd/system/
COPY --from=builder /usr/src/systemd-query-rest/deploy/* /etc/systemd/system/
COPY --from=builder /usr/src/systemd-query-rest/target/release/systemd-query-rest /usr/local/bin/systemd-query-rest

RUN chmod +x /usr/local/bin/* \
    && systemctl enable setup.service mcserv.socket systemd-query-rest.service vsftpd.service 
