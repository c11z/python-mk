# python.mk

A Makefile that contains the seed of a python development environment.

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
* Makefile (consolidation of common tasks)
* Docker (immutable builds)
* [modd](https://github.com/cortesi/modd) (monitor filesystem changes)
* Python 3.7 (hurrah!)
* pytest (pytest)
* [black](https://github.com/ambv/black) (any color)
* [mypy](https://github.com/python/mypy) (static type checking)

The install command generates a project structure
```
tree -a
.
├── Dockerfile
├── .gitignore
├── main.py
├── Makefile
├── modd.conf
├── python.mk
├── requirements.txt
├── scripts
│   └── modd
└── test_main.py
```

The new Makefile extends python.mk so you don't need to ever edit it directly.

Supported commands:
```
make [install, build, format, check, run, test, console]
```
