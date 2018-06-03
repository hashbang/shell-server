SHELL=/bin/bash
PACKER=packer
export CHECKPOINT_DISABLE := 1
export PACKER_CACHE_DIR := \
	$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/.packer/cache
export VERSION := $(shell date -u +%Y%m%d%H%M)

all: clean
	$(PACKER) build --parallel=false packer/build.json

clean:
	rm -rf dist
	rm -rf .packer/build

docker:
	rm -rf dist/*docker*
	rm -rf .packer/build/docker
	$(PACKER) build -only docker packer/build.json

qemu:
	rm -rf dist/*qemu*
	rm -rf .packer/build/qemu
	$(PACKER) build -only qemu packer/build.json

vagrant:
	rm -rf dist/*vagrant*
	rm -rf dist/*virtualbox*
	rm -rf .packer/build/virtualbox
	$(PACKER) build -only virtualbox packer/build.json

lxc:
	rm -rf dist/*vagrant*
	rm -rf dist/*virtualbox*
	rm -rf .packer/build/virtualbox
	$(PACKER) build -only virtualbox packer/build.json

release:
	bash scripts/release.sh

.PHONY: all docker qemu vagrant lxc clean
