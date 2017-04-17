.PHONY: all

all:
	packer build packer.json

docker:
	packer build -only docker packer.json

qemu:
	packer build -only qemu packer.json
