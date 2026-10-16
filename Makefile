# Local development commands (Docker Compose)
DOCKER_COMPOSE = docker compose
SERVICE = jekyll
HOSTNAME = prubiella.traefik.local

# Build the image as the host user, so files written into the repo are not owned by root
export LOCAL_UID := $(shell id -u)
export LOCAL_GID := $(shell id -g)

.PHONY: help setup-hostname build start stop restart logs shell audit

help: ## Show this help message
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup-hostname: ## Add the local hostname to /etc/hosts (asks for sudo)
	@grep -q "$(HOSTNAME)" /etc/hosts || echo "127.0.0.1 $(HOSTNAME)" | sudo tee -a /etc/hosts

build: ## Build the image
	$(DOCKER_COMPOSE) build

start: ## Start the server: http://prubiella.traefik.local and http://127.0.0.1:8082
	$(DOCKER_COMPOSE) up -d

stop: ## Stop the server
	$(DOCKER_COMPOSE) down

restart: ## Restart the server
	$(DOCKER_COMPOSE) restart

logs: ## Follow the Jekyll logs
	$(DOCKER_COMPOSE) logs -f $(SERVICE)

shell: ## Open a shell in the container
	$(DOCKER_COMPOSE) exec $(SERVICE) bash

audit: ## Run the al-folio upgrade and local override audits
	$(DOCKER_COMPOSE) exec $(SERVICE) bundle exec al-folio upgrade audit --no-fail
	$(DOCKER_COMPOSE) exec $(SERVICE) bundle exec al-folio upgrade overrides audit
