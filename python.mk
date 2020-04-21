
# ██████╗ ██╗   ██╗████████╗██╗  ██╗ ██████╗ ███╗   ██╗   ███╗   ███╗██╗  ██╗
# ██╔══██╗╚██╗ ██╔╝╚══██╔══╝██║  ██║██╔═══██╗████╗  ██║   ████╗ ████║██║ ██╔╝
# ██████╔╝ ╚████╔╝    ██║   ███████║██║   ██║██╔██╗ ██║   ██╔████╔██║█████╔╝ 
# ██╔═══╝   ╚██╔╝     ██║   ██╔══██║██║   ██║██║╚██╗██║   ██║╚██╔╝██║██╔═██╗ 
# ██║        ██║      ██║   ██║  ██║╚██████╔╝██║ ╚████║██╗██║ ╚═╝ ██║██║  ██╗
# ╚═╝        ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝

# Makefile for generating python scripting development environment.

.PHONY: install build build_quiet format check watch run test console clean clean_cache

APP_NAME?=main
IMAGE_TAG?=pythonmk:latest
MAINTAINER?=person@example.com
UGID=$(shell id -u):$(shell id -g)

MODD_VERSION = 0.4
INSTALL_TARGETS = scripts \
	scripts/modd modd.conf \
	Makefile \
	Dockerfile \
	requirements.txt \
	env.list \
	$(APP_NAME).py \
	test_$(APP_NAME).py \
	.gitignore

ifeq ($(OS),Darwin)
	MODD_URL = "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-osx64.tgz"
else
	MODD_URL = "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-linux64.tgz"
endif

default: build

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
		--user $(UGID) \
		--volume $(CURDIR):/script \
		$(IMAGE_TAG) \
		/bin/bash -c \
		"python3 -m isort -rc /script && \
		python3 -m autoflake -r --in-place --remove-unused-variables /script && \
		python3 -m black /script"

check: build_quiet
	@docker run \
		--rm \
		--user $(UGID) \
		--volume $(CURDIR):/script \
		$(IMAGE_TAG) \
		python3 -m mypy --ignore-missing-imports /script

run: build_quiet
	@docker run \
		--rm \
		--user $(UGID) \
		--volume $(CURDIR):/script \
		--env-file $(CURDIR)/env.list \
		$(IMAGE_TAG) \
		python3 /script/$(APP_NAME).py

test: build_quiet
	@docker run \
		--rm \
		--user $(UGID) \
		--volume $(CURDIR):/script \
		--env-file $(CURDIR)/env.list \
		--workdir /script \
		$(IMAGE_TAG) \
		python3 -m pytest

console: build_quiet
	@docker run \
		--rm \
		--tty \
		--interactive \
		--user $(UGID) \
		--volume $(CURDIR):/script \
		--env-file $(CURDIR)/env.list \
		--workdir /script \
		$(IMAGE_TAG) \
		/bin/bash

clean: clean_cache

clean_cache:
	find $(CURDIR) \
		-type f -iregex ".*.py[co]" -delete -o \
		-type d -name "__pycache__" -delete -o \
		-type d -name ".mypy_cache" -delete -o \
		-type d -empty -delete

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

env.list:
	@test -s $@ || echo "$$env_list" > $@

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
	prep: make format
	prep: make check
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

RUN apt update && \
	apt upgrade -y && \
	apt install -y \
	tree

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
isort
autoflake
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

define env_list
# Environment variables to be passed to docker containers.
MY_ENV=example
endef
export env_list

define gitignore
*.py[cod]
__pycache__
.mypy_cache
.pytest_cache
scripts/modd
env.list
endef
export gitignore
