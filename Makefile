## Meta data about the image
DOCKER_IMAGE=dsuite/spigot-builder
DOCKER_IMAGE_CREATED=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
DOCKER_IMAGE_REVISION=$(shell git rev-parse --short HEAD)

## Current directory
DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

## Config
.DEFAULT_GOAL := help
.PHONY: *

help: ## This help!
	@printf "\033[33mUsage:\033[0m\n  make [target] [arg=\"val\"...]\n\n\033[33mTargets:\033[0m\n"
	@grep -E '^[-a-zA-Z0-9_\.\/]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build
	@docker build \
		--build-arg http_proxy=${http_proxy} \
		--build-arg https_proxy=${https_proxy} \
		--build-arg no_proxy="${no_proxy}" \
		--file $(DIR)/Dockerfile \
		--tag $(DOCKER_IMAGE):latest \
		$(DIR)

push: ## Push
	@$(MAKE) build
	@docker push $(DOCKER_IMAGE):latest

shell: ## Run shell
	@mkdir -p $(DIR)/tmp/target
	@docker run -it --rm \
		-v $(M2_REPO):/root/.m2 \
		-v $(DIR)/tmp/target:/var/spigot/target \
		--entrypoint /bin/bash \
		$(DOCKER_IMAGE):latest

run:
	@mkdir -p $(DIR)/tmp/target
	@docker run -t --rm \
		-v $(M2_REPO):/root/.m2 \
		-v $(DIR)/tmp/target:/var/spigot/target \
		$(DOCKER_IMAGE):latest 

remove: ## Remove all generated images
	@docker images | grep $(DOCKER_IMAGE) | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi $(DOCKER_IMAGE):{} || true
	@docker images | grep $(DOCKER_IMAGE) | tr -s ' ' | cut -d ' ' -f 3 | xargs -I {} docker rmi {} || true

readme: ## Generate docker hub full description
	@docker run -it --rm \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-e no_proxy="${no_proxy}" \
		-e DOCKER_USERNAME=${DOCKER_USERNAME} \
		-e DOCKER_PASSWORD=${DOCKER_PASSWORD} \
		-e DOCKER_IMAGE=${DOCKER_IMAGE} \
		-v $(DIR)/Readme.md:/data/README.md  \
		dsuite/hub-updater
