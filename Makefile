BUILD_DATE := $$(date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_REF := $$(git rev-parse --short HEAD)
VERSION := $$(grep sphinx== requirements.pip | tr -s '==' | cut -d '=' -f 2)

.DEFAULT_GOAL := help

.PHONY: help
help:
	@grep -E '^[\.a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: ## Remove all Docker images and test artifacts
	rm -fr docs
	docker rmi sphinx-doc:$(VERSION) sphinx-doc:latest sphinx-doc:$(VERSION)-latex sphinx-doc:latex

.PHONY: build-alpine
build-alpine: ## Build Alpine Docker image
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VERSION=$(VERSION) \
		--tag sphinx-doc:$(VERSION) \
		--tag sphinx-doc:latest \
		.

.PHONY: build-debian
build-debian: ## Build Debian Docker image
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VERSION=$(VERSION) \
		--file Dockerfile.latex \
		--tag sphinx-doc:$(VERSION)-latex \
		--tag sphinx-doc:latex \
		.

.PHONY: build
build: build-alpine build-debian ## Build all Docker images
	docker images sphinx-doc

.PHONY: smoke-test-alpine
smoke-test-alpine: ## Run smoke tests for Alpine image
	./bin/test.sh sphinx-doc:$(VERSION)

.PHONY: smoke-test-debian
smoke-test-debian: ## Run smoke tests for Debian image
	./bin/test.sh sphinx-doc:$(VERSION)-latex

.PHONY: smoke-test
smoke-test: smoke-test-alpine smoke-test-debian ## Run all smoke tests
