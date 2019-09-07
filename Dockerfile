FROM docker.io/fedora

EXPOSE 25565/tcp
EXPOSE 25565/udp

VOLUME ["/mcserv"]

RUN dnf --refresh update -y
RUN dnf install java-openjdk-headless -y

COPY ./docker-scripts/init.sh /init.sh

CMD ["/bin/bash", "/init.sh"]
