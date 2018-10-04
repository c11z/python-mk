# python.mk

A Makefile based approach to generate a python development environment.

Inspired by [erlang.mk](https://github.com/ninenines/erlang.mk) and [elm.mk](https://github.com/cloud8421/elm.mk).

To get started,
1. clone this repo
1. make a new project
1. copy python.mk into your new project folder
1. make install

```
git clone git@github.com:c11z/python-mk.git python_mk
mkdir new_project
cp python_mk/python.mk new_project/
cd new_project
make -f python.mk install
```

Technologies:
* Makefile
* Docker
* Python 3.7
* unittest
* [black](https://github.com/ambv/black)
* [mypy](https://github.com/python/mypy)
