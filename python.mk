# Makefile for generating python scripting development environment.git

.PHONY: install build format check watch run test console clean_install

IMAGE=pythonmk:latest
MODD_VERSION = 0.4
INSTALL_TARGETS = scripts \
	scripts/modd modd.conf \
	Makefile \
	Dockerfile \
	requirements.txt \
	main.py \
	test_main.py \
	.gitignore

ifeq ($(OS),Darwin)
	MODD_URL = "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-osx64.tgz"
else
	MODD_URL = "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-linux64.tgz"
endif

install: $(INSTALL_TARGETS)

build:
	@docker build \
		--quiet \
		--tag=$(IMAGE) \
		.

format: build
	@docker run \
		--rm \
		--volume $(CURDIR):/script \
		$(IMAGE) \
		black --quiet /script

check: format
	@docker run \
		--rm \
		--volume $(CURDIR):/script \
		$(IMAGE) \
		python3 -m mypy /script

run: check
	@docker run \
		--rm \
		--volume $(CURDIR):/script \
		$(IMAGE) \
		python3 /script/main.py

test: check
	@docker run \
		--rm \
		--volume $(CURDIR):/script \
		--workdir /script \
		$(IMAGE) \
		python3 -B -m pytest

console: build
	@docker run \
		--rm \
		--tty \
		--interactive \
		--volume $(CURDIR):/script \
		--workdir /script \
		$(IMAGE) \
		/bin/bash

watch:
	scripts/modd

clean_install:
	rm $(INSTALL_TARGETS)

scripts:
	mkdir -p $@

Makefile:
	@test -s $@ || echo "$$Makefile" > $@

Dockerfile:
	@test -s $@ || echo "$$Dockerfile" > $@

requirements.txt:
	@test -s $@ || echo "$$requirements_txt" > $@

main.py:
	@test -s $@ || echo "$$main_py" > $@

test_main.py:
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
endef
export modd_config

define Makefile

include python.mk
endef
export Makefile

define Dockerfile
FROM python:3.7-slim-stretch
LABEL maintainer=corydominguez@gmail.com

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
import main


def test_main():
    assert main.main() == "Hello World"
endef
export test_main_py

define gitignore
*.py[cod]
__pycache__
endef
export gitignore
