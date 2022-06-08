FROM rustlang/rust:nightly-bullseye-slim AS builder
WORKDIR /usr/src/systemd-query-rest
COPY systemd-query-rest ./
RUN cargo build --release


FROM jrei/systemd-debian:11

ARG PINCLUDE_WINE=1

VOLUME ["/opt/dedicated-server", "/sys/fs/cgroup", "/tmp", "/run", "/run/lock"]

EXPOSE 8000/tcp
EXPOSE 21/tcp

ENV DDSERV_UID=0
ENV DDSERV_GID=0
ENV DDSERV_ACTIVATE_PORT=27015/udp
ENV DDSERV_TIMEOUT=15min
ENV DDSERV_EXIT_SUCCESS_CODE=0
ENV DDSERV_LOG_SOURCE=journald
ENV DDSERV_LOG_FILE=
ENV DDSERV_STEAM_APP_ID=
ENV DDSERV_STEAM_FORCE_PLATFORM=
ENV DDSERV_PASSWORD=
ENV DDSERV_JOIN_PATTERN=
ENV DDSERV_LEAVE_PATTERN=

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y software-properties-common \
    && apt-add-repository non-free \
    && echo steamcmd steam/question select 'I AGREE' | debconf-set-selections

RUN apt-get update \
    && apt-get install -y vsftpd steamcmd

RUN useradd --system --user-group --create-home --shell /usr/sbin/nologin ddserv \
    && echo '/usr/sbin/nologin' >> /etc/shells \
    && sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf

RUN apt-get install -y locales \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure locales

RUN if [ $PINCLUDE_WINE = 1 ]; then apt-get install -y xvfb wine64 wine32; fi

RUN su --shell /bin/bash --command "steamcmd +quit" - ddserv

COPY scripts/container-setup.sh /usr/local/bin/container-setup
COPY scripts/dedicated-server-timerctrl.sh /usr/local/bin/dedicated-server-timerctrl
COPY systemd-units/* /etc/systemd/system/

COPY --from=builder /usr/src/systemd-query-rest/deploy/* /etc/systemd/system/
COPY --from=builder /usr/src/systemd-query-rest/target/release/systemd-query-rest /usr/local/bin/systemd-query-rest

RUN chmod +x /usr/local/bin/container-setup /usr/local/bin/dedicated-server-timerctrl /usr/local/bin/systemd-query-rest \
    && systemctl enable container-setup.service dedicated-server.socket systemd-query-rest.service vsftpd.service 
