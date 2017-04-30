.PHONY: all docker qemu vagrant clean

SHELL=/bin/bash
export PACKER_CACHE_DIR := \
	$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/.packer/cache
export VERSION := $(shell date -u +%Y%m%d%H%M)

clean:
	rm -rf dist
	rm -rf .packer/build

all: clean docker qemu vagrant

docker:
	rm -rf dist/*docker*
	rm -rf .packer/build/docker
	packer build -only docker packer/build.json

qemu:
	rm -rf dist/*qemu*
	rm -rf .packer/build/qemu
	packer build -only qemu packer/build.json

vagrant:
	rm -rf dist/*vagrant*
	rm -rf dist/*virtualbox*
	rm -rf .packer/build/virtualbox
	packer build -only virtualbox packer/build.json

publish:
	for file in dist/*; do \
		gpg \
			--local-user D2C4C74D8FAA96F5 \
			--detach-sig \
			$$file ; \
	done
	packer build packer/publish.json
