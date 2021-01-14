FROM dsuite/maven:3.6-jdk-8

LABEL maintainer="Hexosse <hexosse@gmail.com>" \
    org.opencontainers.image.title="docker-suite dsuite/spigot-builder:latest image" \
    org.opencontainers.image.description="A Spigot, craftbukkit image builder" \
    org.opencontainers.image.authors="Hexosse <hexosse@gmail.com>" \
    org.opencontainers.image.vendor="docker-suite" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/docker-suite/spigot-builder" \
    org.opencontainers.image.source="https://github.com/docker-suite/spigot-builder" \
    org.opencontainers.image.documentation="https://github.com/docker-suite/spigot-builder/blob/master/Readme.md" \
    org.opencontainers.image.created="{{DOCKER_IMAGE_CREATED}}" \
    org.opencontainers.image.revision="{{DOCKER_IMAGE_REVISION}}"

ENV USER_NAME=${USER_NAME:-Hexosse}
ENV USER_EMAIL=${USER_EMAIL:-hexosse@gmail.com}

## Scripts
COPY rootfs /
RUN sudo chmod +x /var/spigot/spigot-build.sh

## Working folder
WORKDIR /var/spigot

## Persist data
VOLUME [ "/var/spigot/build", "/var/spigot/target", "/root/.m2" ]

## Define entrypoint to directly build spigot and craftbukkit
ENTRYPOINT [ "/var/spigot/spigot-build.sh" ]
CMD ["latest"]
