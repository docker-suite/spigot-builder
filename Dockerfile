FROM dsuite/maven:3.6-jdk8

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
RUN sudo chmod +x /var/maven_home/spigot-build.sh

## Working folder
WORKDIR /var/maven_home

## Persist data
VOLUME [ "/var/maven_home/build", "/var/maven_home/target", "/var/maven_home/.m2" ]

## Define entrypoint to directly build spigot and craftbukkit
ENTRYPOINT [ "/bin/bash", "-c", "/var/maven_home/spigot-build.sh" ]
CMD ["latest"]
