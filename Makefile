VAGRANT=vagrant
DOCKER_MACHINE=docker-machine
DOCKER_MACHINE_ENV=$(DOCKER_MACHINE) env
DOCKER_SWITCH_WINDOWS=eval $$($(DOCKER_MACHINE_ENV) windows)
DOCKER_SWITCH_MAC=eval $$($(DOCKER_MACHINE_ENV) -unset)
DOCKER=docker
DOCKER_BUILD=$(DOCKER) build
DOCKER_RUN=$(DOCKER) run

.PHONY: help deps vm docker-build-dev docker-build-prod docker-check-dev docker-check-prod docker-run-dev docker-run-prod

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

deps: ## Install required dependencies.
	./scripts/deps.sh

list: ## List all Docker Machines.
	$(DOCKER_MACHINE) ls

vm: ## Brings up the Windows VM.
	$(VAGRANT) up \
		--provider virtualbox \
		--provision \
		windows_2019_docker

ip: ## Retrieves the Windows Docker IP.
	$(DOCKER_SWITCH_WINDOWS); \
	$(DOCKER_MACHINE) ip windows; \
	$(DOCKER_SWITCH_MAC);

open: ## Opens a browser on the sample app IP and port.
	open "http://$$($(DOCKER_MACHINE) ip windows):8000"

docker-clean:
	if [ ! -z $$(echo $$($(DOCKER) images -f dangling=true -q) | awk '{print $$1;}') ]; then $(DOCKER) rmi -f $$($(DOCKER) images -f dangling=true -q); fi

docker-build-dev: ## Build the development Docker image.
	$(DOCKER_SWITCH_WINDOWS); \
	$(DOCKER_BUILD) --file $(PWD)/dev.Dockerfile --tag sample:dev .; \
	$(MAKE) docker-clean; \
	$(DOCKER_SWITCH_MAC);

docker-build-prod: ## Build the production Docker image.
	$(DOCKER_SWITCH_WINDOWS); \
	$(DOCKER_BUILD) --file $(PWD)/prod.Dockerfile --tag sample:prod .; \
	$(MAKE) docker-clean; \
	$(DOCKER_SWITCH_MAC);

docker-check-dev:
	if [ -z $$($(DOCKER) images sample:dev -q) ]; then $(MAKE) docker-build-dev; fi;

docker-check-prod:
	if [ -z $$($(DOCKER) images sample:prod -q) ]; then $(MAKE) docker-build-prod; fi;

docker-run-dev: ## Run the development Docker container.
	$(DOCKER_SWITCH_WINDOWS); \
	$(MAKE) docker-check-dev; \
	$(DOCKER_RUN) \
		--volume C:$(PWD)/sample:C:/app \
		--name sample-dev \
		--tty \
		--interactive \
		--rm \
		--publish 8000:80 \
		sample:dev \
		powershell -Command 'pm2 start watcher.js; powershell'
	$(DOCKER_SWITCH_MAC);

docker-run-prod: ## Run the production Docker container.
	$(DOCKER_SWITCH_WINDOWS); \
	$(MAKE) docker-check-prod; \
	$(DOCKER_RUN) \
		--name sample-prod \
		--detach \
		--rm \
		--publish 8000:80 \
		sample:prod
	$(DOCKER_SWITCH_MAC);

