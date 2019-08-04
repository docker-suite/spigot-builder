DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
PROJECT_NAME:=$(strip $(shell basename $(DIR)))
DOCKER_IMAGE=dsuite/$(PROJECT_NAME)


build-all:
	SPIGOT_VERSION=1.8    $(MAKE) build
	SPIGOT_VERSION=1.8.3  $(MAKE) build
	SPIGOT_VERSION=1.8.7  $(MAKE) build
	SPIGOT_VERSION=1.8.8  $(MAKE) build
	SPIGOT_VERSION=1.9    $(MAKE) build
	SPIGOT_VERSION=1.9.2  $(MAKE) build
	SPIGOT_VERSION=1.9.4  $(MAKE) build
	SPIGOT_VERSION=1.10   $(MAKE) build
	SPIGOT_VERSION=1.11   $(MAKE) build
	SPIGOT_VERSION=1.12   $(MAKE) build
	SPIGOT_VERSION=1.12.1 $(MAKE) build
	SPIGOT_VERSION=1.12.2 $(MAKE) build
	SPIGOT_VERSION=1.13   $(MAKE) build
	SPIGOT_VERSION=1.13.1 $(MAKE) build
	SPIGOT_VERSION=1.13.2 $(MAKE) build
	SPIGOT_VERSION=1.14   $(MAKE) build
	SPIGOT_VERSION=1.14.1 $(MAKE) build
	SPIGOT_VERSION=1.14.2 $(MAKE) build
	SPIGOT_VERSION=1.14.3 $(MAKE) build
	SPIGOT_VERSION=1.14.4 $(MAKE) build

test-all:
	SPIGOT_VERSION=1.8    $(MAKE) test
	SPIGOT_VERSION=1.8.3  $(MAKE) test
	SPIGOT_VERSION=1.8.7  $(MAKE) test
	SPIGOT_VERSION=1.8.8  $(MAKE) test
	SPIGOT_VERSION=1.9    $(MAKE) test
	SPIGOT_VERSION=1.9.2  $(MAKE) test
	SPIGOT_VERSION=1.9.4  $(MAKE) test
	SPIGOT_VERSION=1.10   $(MAKE) test
	SPIGOT_VERSION=1.11   $(MAKE) test
	SPIGOT_VERSION=1.12   $(MAKE) test
	SPIGOT_VERSION=1.12.1 $(MAKE) test
	SPIGOT_VERSION=1.12.2 $(MAKE) test
	SPIGOT_VERSION=1.13   $(MAKE) test
	SPIGOT_VERSION=1.13.1 $(MAKE) test
	SPIGOT_VERSION=1.13.2 $(MAKE) test
	SPIGOT_VERSION=1.14   $(MAKE) test
	SPIGOT_VERSION=1.14.1 $(MAKE) test
	SPIGOT_VERSION=1.14.2 $(MAKE) test
	SPIGOT_VERSION=1.14.3 $(MAKE) test
	SPIGOT_VERSION=1.14.4 $(MAKE) test

push-all:
	SPIGOT_VERSION=1.8    $(MAKE) push
	SPIGOT_VERSION=1.8.3  $(MAKE) push
	SPIGOT_VERSION=1.8.7  $(MAKE) push
	SPIGOT_VERSION=1.8.8  $(MAKE) push
	SPIGOT_VERSION=1.9    $(MAKE) push
	SPIGOT_VERSION=1.9.2  $(MAKE) push
	SPIGOT_VERSION=1.9.4  $(MAKE) push
	SPIGOT_VERSION=1.10   $(MAKE) push
	SPIGOT_VERSION=1.11   $(MAKE) push
	SPIGOT_VERSION=1.12   $(MAKE) push
	SPIGOT_VERSION=1.12.1 $(MAKE) push
	SPIGOT_VERSION=1.12.2 $(MAKE) push
	SPIGOT_VERSION=1.13   $(MAKE) push
	SPIGOT_VERSION=1.13.1 $(MAKE) push
	SPIGOT_VERSION=1.13.2 $(MAKE) push
	SPIGOT_VERSION=1.14   $(MAKE) push
	SPIGOT_VERSION=1.14.1 $(MAKE) push
	SPIGOT_VERSION=1.14.2 $(MAKE) push
	SPIGOT_VERSION=1.14.3 $(MAKE) push
	SPIGOT_VERSION=1.14.4 $(MAKE) push

build:
	@docker run --rm \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-e SPIGOT_VERSION=$(SPIGOT_VERSION) \
		-v $(DIR)/Dockerfiles:/data \
		dsuite/alpine-data \
		sh -c "templater Dockerfile.template > Dockerfile-$(SPIGOT_VERSION)"
	docker build \
		--build-arg http_proxy=${http_proxy} \
		--build-arg https_proxy=${https_proxy} \
		--file $(DIR)/Dockerfiles/Dockerfile-$(SPIGOT_VERSION) \
		--tag $(DOCKER_IMAGE):$(SPIGOT_VERSION) \
		$(DIR)/Dockerfiles

test: build
	@docker run --rm -t \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-v $(DIR)/tests:/goss \
		-v /tmp:/tmp \
		-v /var/run/docker.sock:/var/run/docker.sock \
		dsuite/goss:latest \
		dgoss run -e SPIGOT_VERSION=$(SPIGOT_VERSION) --entrypoint=/goss/entrypoint.sh $(DOCKER_IMAGE):$(SPIGOT_VERSION)

push: build
	@docker push $(DOCKER_IMAGE):$(SPIGOT_VERSION)

run-dir:
	mkdir -p $$PWD/.tmp/.m2
	mkdir -p $$PWD/.tmp/target

run: run-dir build
	@docker run -it --rm \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-v $$PWD/.tmp/.m2:/var/maven_home/.m2 \
		-v $$PWD/.tmp/target:/var/maven_home/target \
		$(DOCKER_IMAGE):$(SPIGOT_VERSION)

remove:
	@docker images | grep $(DOCKER_IMAGE) | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi $(DOCKER_IMAGE):{} || true
	@docker images | grep $(DOCKER_IMAGE) | tr -s ' ' | cut -d ' ' -f 3 | xargs -I {} docker rmi {} || true

readme:
	@docker run -t --rm \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-e DOCKER_USERNAME=${DOCKER_USERNAME} \
		-e DOCKER_PASSWORD=${DOCKER_PASSWORD} \
		-e DOCKER_IMAGE=${DOCKER_IMAGE} \
		-v $(DIR):/data \
		dsuite/hub-updater
