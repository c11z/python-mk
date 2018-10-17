# Makefile for generating python scripting development environment.git

.PHONY: install build build_quiet format check watch run test console

APP_NAME?=main
IMAGE_TAG?=pythonmk:latest
MAINTAINER?=person@example.com

MODD_VERSION = 0.4
INSTALL_TARGETS = scripts \
	scripts/modd modd.conf \
	Makefile \
	Dockerfile \
	requirements.txt \
	$(APP_NAME).py \
	test_$(APP_NAME).py \
	.gitignore

ifeq ($(OS),Darwin)
	MODD_URL = "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-osx64.tgz"
else
	MODD_URL = "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-linux64.tgz"
endif

install: $(INSTALL_TARGETS)

build_quiet:
	@docker build \
		--quiet \
		--tag=$(IMAGE_TAG) \
		.

build:
	@docker build \
		--tag=$(IMAGE_TAG) \
		.

format: build_quiet
	@docker run \
		--rm \
		--volume $(CURDIR):/script \
		$(IMAGE_TAG) \
		black --quiet /script

check: format
	@docker run \
		--rm \
		--volume $(CURDIR):/script \
		$(IMAGE_TAG) \
		python3 -m mypy /script

run: build_quiet
	@docker run \
		--rm \
		--volume $(CURDIR):/script \
		$(IMAGE_TAG) \
		python3 /script/$(APP_NAME).py

test: check
	@docker run \
		--rm \
		--volume $(CURDIR):/script \
		--workdir /script \
		$(IMAGE_TAG) \
		python3 -B -m pytest -p no:cacheprovider

console: build_quiet
	@docker run \
		--rm \
		--tty \
		--interactive \
		--volume $(CURDIR):/script \
		--workdir /script \
		$(IMAGE_TAG) \
		/bin/bash

watch:
	scripts/modd

scripts:
	mkdir -p $@

Makefile:
	@test -s $@ || echo "$$Makefile" > $@

Dockerfile:
	@test -s $@ || echo "$$Dockerfile" > $@

requirements.txt:
	@test -s $@ || echo "$$requirements_txt" > $@

$(APP_NAME).py:
	@test -s $@ || echo "$$main_py" > $@

test_$(APP_NAME).py:
	@test -s $@ || echo "$$test_main_py" > $@

.gitignore:
	@test -s $@ || echo "$$gitignore" > $@

scripts/modd:
	curl ${MODD_URL} -L -o $@.tgz
	tar -xzf $@.tgz -C scripts/ --strip 1
	rm $@.tgz

modd.conf:
	echo "$$modd_config" > $@

define modd_config
**/*.py {
	prep: make test
}
Dockerfile requests.txt {
	prep: make build
}
endef
export modd_config

define Makefile
APP_NAME=$(APP_NAME)
IMAGE_TAG=$(IMAGE_TAG)
MAINTAINER=$(MAINTAINER)

include python.mk
endef
export Makefile

define Dockerfile
FROM python:3.7-slim-stretch
LABEL maintainer=$(MAINTAINER)

COPY requirements.txt /
RUN pip install -r /requirements.txt
endef
export Dockerfile
define requirements_txt
# Application

# Development
black
pytest
mypy
endef
export requirements_txt

define main_py
def main() -> str:
    return "Hello World"


if __name__ == "__main__":
    greeting = main()
    print(greeting)
endef
export main_py

define test_main_py
import $(APP_NAME)


def test_$(APP_NAME)():
    assert $(APP_NAME).main() == "Hello World"
endef
export test_main_py

define gitignore
*.py[cod]
__pycache__
scripts/modd
endef
export gitignore
