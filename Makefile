## Meta data about the image
DOCKER_IMAGE=dsuite/spigot-builder
DOCKER_IMAGE_CREATED=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
DOCKER_IMAGE_REVISION=$(shell git rev-parse --short HEAD)

## Current directory
DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

##
base_image = dsuite/maven:3.8-openjdk-16
image_name = 16

## Config
.DEFAULT_GOAL := help
.PHONY: *

help: ## This help!
	@printf "\033[33mUsage:\033[0m\n  make [target] [arg=\"val\"...]\n\n\033[33mTargets:\033[0m\n"
	@grep -E '^[-a-zA-Z0-9_\.\/]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-15s\033[0m %s\n", $$1, $$2}'

build-all: ## Build all supported versions
	@$(MAKE) build	base=dsuite/maven:3.8-openjdk-8		name=8
	@$(MAKE) build	base=dsuite/maven:3.8-openjdk-16	name=16

build: ## Build
	$(eval base := $(or $(b),$(base),$(base_image)))
	$(eval name := $(or $(n),$(name),$(image_name)))
	@docker run --rm \
		-e BASE_IMAGE=$(base) \
		-e DOCKER_IMAGE_CREATED=$(DOCKER_IMAGE_CREATED) \
		-e DOCKER_IMAGE_REVISION=$(DOCKER_IMAGE_REVISION) \
		-v $(DIR)/Dockerfiles:/data \
		dsuite/alpine-data \
		sh -c "templater Dockerfile.template > Dockerfile-$(name)"
	@docker build \
		--file $(DIR)/Dockerfiles/Dockerfile-$(name) \
		--tag $(DOCKER_IMAGE):$(name) \
		$(DIR)/Dockerfiles
	@[ "$(name)" = "$(image_name)" ] && docker tag $(DOCKER_IMAGE):$(name) $(DOCKER_IMAGE):latest || true

push-all: ## Build all supported versions
	@$(MAKE) push n=8
	@$(MAKE) push n=16
	@$(MAKE) push n=latest

push: ## Push
	$(eval name := $(or $(n),$(name),$(image_name)))
	@docker push $(DOCKER_IMAGE):$(name)

shell: ## Run shell
	@mkdir -p $(DIR)/tmp/target
	@docker run -it --rm \
		-v $(M2_REPO):/root/.m2 \
		-v spigot_build:/var/spigot/build \
		-v $(DIR)/tmp/target:/var/spigot/target \
		--entrypoint /bin/bash \
		$(DOCKER_IMAGE):latest

spigot-build:
	$(eval image_version := $(or $(i),$(image)))
	$(eval spigot_version := $(or $(v),$(version)))
	@mkdir -p $(DIR)/tmp/target
	@docker run -it --rm \
		-v $(M2_REPO):/root/.m2 \
		-v spigot_build:/var/spigot/build \
		-v $(DIR)/tmp/target:/var/spigot/target \
		$(DOCKER_IMAGE):$(image_version) \
		$(spigot_version)

spigot-build-all:
	@$(MAKE) spigot-build image=8   version=1.8
	@$(MAKE) spigot-build image=8   version=1.8.3
	@$(MAKE) spigot-build image=8   version=1.8.8
	@$(MAKE) spigot-build image=8   version=1.9
	@$(MAKE) spigot-build image=8   version=1.9.2
	@$(MAKE) spigot-build image=8   version=1.9.4
	@$(MAKE) spigot-build image=8   version=1.10.2
	@$(MAKE) spigot-build image=8   version=1.11
	@$(MAKE) spigot-build image=8   version=1.11.1
	@$(MAKE) spigot-build image=8   version=1.11.2
	@$(MAKE) spigot-build image=8   version=1.12
	@$(MAKE) spigot-build image=8   version=1.12.1
	@$(MAKE) spigot-build image=8   version=1.12.2
	@$(MAKE) spigot-build image=8   version=1.13
	@$(MAKE) spigot-build image=8   version=1.13.1
	@$(MAKE) spigot-build image=8   version=1.13.2
	@$(MAKE) spigot-build image=8   version=1.14
	@$(MAKE) spigot-build image=8   version=1.14.1
	@$(MAKE) spigot-build image=8   version=1.14.2
	@$(MAKE) spigot-build image=8   version=1.14.3
	@$(MAKE) spigot-build image=8   version=1.14.4
	@$(MAKE) spigot-build image=8   version=1.15
	@$(MAKE) spigot-build image=8   version=1.15.1
	@$(MAKE) spigot-build image=8   version=1.15.2
	@$(MAKE) spigot-build image=8   version=1.16.1
	@$(MAKE) spigot-build image=8   version=1.16.2
	@$(MAKE) spigot-build image=8   version=1.16.3
	@$(MAKE) spigot-build image=8   version=1.16.4
	@$(MAKE) spigot-build image=8   version=1.16.5
	@$(MAKE) spigot-build image=16  version=1.17
	@$(MAKE) spigot-build image=16  version=1.17.1


remove: ## Remove all generated images
	@docker images | grep $(DOCKER_IMAGE) | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi $(DOCKER_IMAGE):{} || true
	@docker images | grep $(DOCKER_IMAGE) | tr -s ' ' | cut -d ' ' -f 3 | xargs -I {} docker rmi {} || true

readme: ## Generate docker hub full description
	@docker run -it --rm \
		-e DOCKER_USERNAME=${DOCKER_USERNAME} \
		-e DOCKER_PASSWORD=${DOCKER_PASSWORD} \
		-e DOCKER_IMAGE=${DOCKER_IMAGE} \
		-v $(DIR)/Readme.md:/data/README.md  \
		dsuite/hub-updater
