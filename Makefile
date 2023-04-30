SHELL=/bin/bash
PACKER=packer
export CHECKPOINT_DISABLE := 1
export PACKER_CACHE_DIR := \
	$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/.packer/cache
export VERSION := $(shell date -u +%Y%m%d%H%M)
EXECUTABLES = $(PACKER) ansible
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))
WHICH-%: ; @which $* > /dev/null

all: clean WHICH-qemu-system-x86_64
	$(PACKER) build --parallel=false packer/build.json

clean:
	mkdir -p dist
	rm -rf dist/*
	rm -rf .packer/build

docker:
	mkdir -p dist
	rm -rf dist/*docker*
	rm -rf .packer/build/docker
	$(PACKER) build -only docker packer/build.json

qemu: WHICH-qemu-system-x86_64
	mkdir -p dist
	rm -rf dist/*qemu*
	rm -rf .packer/build/qemu
	$(PACKER) build -only qemu packer/build.json

vagrant:
	mkdir -p dist
	rm -rf dist/*vagrant*
	rm -rf dist/*virtualbox*
	rm -rf .packer/build/virtualbox
	$(PACKER) build -only virtualbox packer/build.json

lxc:
	mkdir -p dist
	rm -rf dist/*lxc*
	rm -rf .packer/build/lxc
	$(PACKER) build -only lxc packer/build.json

lxd:
	mkdir -p dist
	rm -rf dist/*lxd*
	rm -rf .packer/build/lxd
	$(PACKER) build -only lxd packer/build.json

release:
	bash scripts/release.sh

.PHONY: all docker qemu vagrant lxc clean
