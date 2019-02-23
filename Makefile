VAGRANT=vagrant
DOCKER_MACHINE=docker-machine
DOCKER_MACHINE_ENV=$(DOCKER_MACHINE) env
DOCKER_SWITCH_WINDOWS=eval $$($(DOCKER_MACHINE_ENV) windows)
DOCKER_SWITCH_MAC=eval $$($(DOCKER_MACHINE_ENV) -unset)
DOCKER=docker
DOCKER_BUILD=$(DOCKER) build
DOCKER_RUN=$(DOCKER) run

.PHONY: help all build-dev build-prod build-vm check-dev check-prod clean deps docker-clean open run-dev run-prod

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: ## Performs setup and starts dev experience.
	$(MAKE) clean; \
	$(MAKE) deps; \
	$(MAKE) build-vm; \
	$(MAKE) build-dev; \
	$(MAKE) open; \
	$(MAKE) run-dev;

build-dev: ## Build the development Docker image.
	$(DOCKER_SWITCH_WINDOWS); \
	$(DOCKER_BUILD) --file $(PWD)/dev.Dockerfile --tag sample:dev .; \
	$(MAKE) docker-clean; \
	$(DOCKER_SWITCH_MAC);

build-prod: ## Build the production Docker image.
	$(DOCKER_SWITCH_WINDOWS); \
	$(DOCKER_BUILD) --file $(PWD)/prod.Dockerfile --tag sample:prod .; \
	$(MAKE) docker-clean; \
	$(DOCKER_SWITCH_MAC);

build-vm: ## Brings up the Windows VM.
	$(VAGRANT) up \
		--provider virtualbox \
		--provision \
		windows_2019_docker

check-dev:
	if [ -z $$($(DOCKER) images sample:dev -q) ]; then $(MAKE) build-dev; fi;

check-prod:
	if [ -z $$($(DOCKER) images sample:prod -q) ]; then $(MAKE) build-prod; fi;

clean: ## Cleans up.
	rm -r .vagrant > /dev/null 2>&1 || true; \
	rm -r ./sample/packages > /dev/null 2>&1 || true; \
	rm -r ./sample/aspnetapp/bin > /dev/null 2>&1 || true; \
	rm -r ./sample/aspnetapp/obj > /dev/null 2>&1 || true;

deps: ## Install required dependencies.
	./scripts/deps.sh

docker-clean:
	if [ ! -z $$(echo $$($(DOCKER) images -f dangling=true -q) | awk '{print $$1;}') ]; then $(DOCKER) rmi -f $$($(DOCKER) images -f dangling=true -q); fi

open: ## Opens the sample app in the browser.
	open "http://$$($(DOCKER_MACHINE) ip windows):8000"

run-dev: ## Run the development Docker container.
	$(DOCKER_SWITCH_WINDOWS); \
	$(MAKE) check-dev; \
	$(DOCKER_RUN) \
		--volume C:$(PWD)/sample:C:/app \
		--name sample-dev \
		--tty \
		--interactive \
		--rm \
		--publish 8000:80 \
		sample:dev \
		powershell -Command 'pm2 start C:\watcher.js; powershell'
	$(DOCKER_SWITCH_MAC);

run-prod: ## Run the production Docker container.
	$(DOCKER_SWITCH_WINDOWS); \
	$(MAKE) check-prod; \
	$(DOCKER_RUN) \
		--name sample-prod \
		--detach \
		--rm \
		--publish 8000:80 \
		sample:prod
	$(DOCKER_SWITCH_MAC);
