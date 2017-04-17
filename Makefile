.PHONY: all docker qemu clean

clean:
	rm -rf dist

all: clean
	packer build packer.json

docker: clean
	packer build -only docker packer.json

qemu: clean
	packer build -only qemu packer.json
