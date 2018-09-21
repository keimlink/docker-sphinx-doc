FIND_EXCLUDE_PATHS ?= -not -path './.*/*' -not -path './node_modules/*'
IMAGE_NAME ?= sphinx-doc
SHELLCHECK ?= docker-compose run --rm shellcheck

.DEFAULT_GOAL := help

.PHONY: help
help:
	@grep -E '^[\.a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build-latest
build-latest: ## Build latest image
	./bin/image.sh build $(IMAGE_NAME) latest

.PHONY: build-latex
build-latex: ## Build latex image
	./bin/image.sh build $(IMAGE_NAME) latex

.PHONY: build
build: build-latest build-latex ## Build all images
	docker images $(IMAGE_NAME)

.PHONY: clean
clean: ## Remove all images and test artifacts
	rm -fr docs
	docker rmi --force $$(docker images --quiet $(IMAGE_NAME)* | uniq)

.PHONY: fix
fix: ## Run xo and fix files in-place
	docker-compose run --rm node yarn xo --fix

.PHONY: shellcheck
shellcheck: ## Run shellcheck
	find . $(FIND_EXCLUDE_PATHS) -name "*.sh" -exec $(SHELLCHECK) {} +

.PHONY: lint
lint: shellcheck ## Run lint checks
	docker-compose run --rm node yarn lint
	docker-compose run --rm yamllint

.PHONY: prettier
prettier: ## Rewrite all files that are different from Prettier formatting
	docker-compose run --rm node yarn prettier-write

.PHONY: release
release: ## Pull develop and master, merge develop into master, tag and push release
	@./bin/image.sh release

.PHONY: shell
shell: ## Run a shell in the node container
	docker-compose run --rm node sh

.PHONY: smoke-test-latest
smoke-test-latest: ## Run smoke tests for latest image
	./bin/image.sh test $(IMAGE_NAME) latest

.PHONY: smoke-test-latex
smoke-test-latex: ## Run smoke tests for latex image
	./bin/image.sh test $(IMAGE_NAME) latex

.PHONY: smoke-test
smoke-test: smoke-test-latest smoke-test-latex ## Run all smoke tests
