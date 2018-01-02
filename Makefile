IMAGE_NAME ?= keimlink/sphinx-doc
VERSION := $$(grep --color=no ^sphinx== requirements.pip | tr -s '==' | cut -d '=' -f 2)

.DEFAULT_GOAL := help

.PHONY: help
help:
	@grep -E '^[\.a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: ## Remove all images and test artifacts
	rm -fr docs
	docker rmi $(IMAGE_NAME):$(VERSION) \
		$(IMAGE_NAME):latest \
		$(IMAGE_NAME):$(VERSION)-latex \
		$(IMAGE_NAME):latex

.PHONY: build-latest
build-latest: ## Build latest image
	./bin/build.sh $(IMAGE_NAME) latest

.PHONY: build-latex
build-latex: ## Build latex image
	./bin/build.sh $(IMAGE_NAME) latex

.PHONY: build
build: build-latest build-latex ## Build all images
	docker images $(IMAGE_NAME)

.PHONY: smoke-test-latest
smoke-test-latest: ## Run smoke tests for latest image
	./bin/test.sh $(IMAGE_NAME) latest

.PHONY: smoke-test-latex
smoke-test-latex: ## Run smoke tests for latex image
	./bin/test.sh $(IMAGE_NAME) latex

.PHONY: smoke-test
smoke-test: smoke-test-latest smoke-test-latex ## Run all smoke tests
