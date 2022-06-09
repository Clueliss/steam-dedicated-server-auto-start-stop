FROM jrei/systemd-debian:11

ARG PINCLUDE_COCKPIT=1
ARG PINCLUDE_FTP=1
ARG PADDITIONAL_PACKAGES=

ENV DDSERV_UID=
ENV DDSERV_GID=
ENV DDSERV_PASSWORD=

ENV DDSERV_STEAM_APP_ID=
ENV DDSERV_STEAM_FORCE_PLATFORM=

ENV DDSERV_ACTIVATE_PORT=
ENV DDSERV_LOG_SOURCE=journald
ENV DDSERV_LOG_FILE=
ENV DDSERV_JOIN_PATTERN=
ENV DDSERV_LEAVE_PATTERN=

ENV DDSERV_EXIT_SUCCESS_CODE=
ENV DDSERV_KILL_MODE=

ENV DDSERV_TIMEOUT=

ENV DDSERV_COCKPIT_PORT=
ENV DDSERV_FTP_PORT=


VOLUME ["/opt/dedicated-server", "/sys/fs/cgroup", "/tmp", "/run", "/run/lock"]

RUN useradd --system --user-group --groups systemd-journal --create-home --shell /bin/bash ddserv 

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y software-properties-common psmisc procps \
    && apt-add-repository non-free \
    && echo steamcmd steam/question select 'I AGREE' | debconf-set-selections

RUN apt-get update \
    && apt-get install -y locales steamcmd \
    && sed -i 's/# en_US\.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure locales

RUN su --command "steamcmd +quit" - ddserv

RUN if [ $PINCLUDE_FTP = 1 ]; then \
        apt-get install -y vsftpd; \
        sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf; \
        systemctl enable vsftpd.service; \
    fi

RUN if [ $PINCLUDE_COCKPIT = 1 ]; then \
        apt-get install -y --no-install-recommends cockpit; \
        systemctl enable cockpit.socket; \
    fi

RUN if [ -n "$PADDITIONAL_PACKAGES" ]; then \
        apt-get install -y $PADDITIONAL_PACKAGES; \
    fi

COPY scripts/container-setup.sh /usr/local/bin/container-setup
COPY scripts/dedicated-server-timerctrl.sh /usr/local/bin/dedicated-server-timerctrl
COPY systemd-units/* /etc/systemd/system/

RUN chmod +x /usr/local/bin/container-setup /usr/local/bin/dedicated-server-timerctrl \
    && systemctl enable container-setup.service dedicated-server.socket
