# ![](https://github.com/docker-suite/artwork/raw/master/logo/png/logo_32.png) spigot-builder
[![Build Status](http://jenkins.hexocube.fr/job/docker-suite/job/spigot-builder/badge/icon?color=green&style=flat-square)](http://jenkins.hexocube.fr/job/docker-suite/job/spigot-builder/)
![Docker Pulls](https://img.shields.io/docker/pulls/dsuite/spigot-builder.svg?style=flat-square)
![Docker Stars](https://img.shields.io/docker/stars/dsuite/spigot-builder.svg?style=flat-square)
![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/dsuite/spigot-builder/latest.svg?style=flat-square)
![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/dsuite/spigot-builder/latest.svg?style=flat-square)
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg?style=flat-square)](https://opensource.org/licenses/MIT)

A [spigot][spigot] builder image.

## ![](https://github.com/docker-suite/artwork/raw/master/various/pin/png/pin_16.png) Volumes
- /root/.m2
- /var/spigot/build
- /var/spigot/target

## ![](https://github.com/docker-suite/artwork/raw/master/various/pin/png/pin_16.png) How to use this image

```bash
@docker run -t --rm \
    -v $PWD/.tmp/.m2:/root/.m2 \
    -v $PWD/.tmp/target:/var/spigot/target \
    dsuite/spigot-builder $(SPIGOT_VERSION)
```


[spigot]: https://www.spigotmc.org/
[spigot-builder]: https://github.com/docker-suite/spigot-builder/
