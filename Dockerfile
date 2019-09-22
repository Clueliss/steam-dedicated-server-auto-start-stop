FROM docker.io/fedora

EXPOSE 25565/tcp
EXPOSE 25565/udp

VOLUME ["/mcserv"]

RUN dnf --refresh update -y
RUN dnf install java-1.8.0-openjdk-headless -y

COPY ./scripts/docker/init /init

CMD ["/init"]
