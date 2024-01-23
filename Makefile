#!/bin/sh

HOSTS_PATH=./hosts
TARGET=${HOSTS_PATH}/$(host)

check-target:
ifeq ("$(host)", "")
	$(error "Host not set")
endif

check-env: 
ifeq ("${IN_NIX_SHELL}", "")
	$(error "Not in Nix shell")
endif
	echo In Nix shell: ${IN_NIX_SHELL}

lint: check-env
	alejandra .

nixos.build: check-env check-target
	sudo nixos-rebuild build -I nixos-config=${TARGET}

nixos.dry-build: check-env check-target
	sudo nixos-rebuild dry-build -I nixos-config=${TARGET}

nixos.switch: check-env check-target
	sudo nixos-rebuild switch -I nixos-config=${TARGET}

nixos.upgrade: check-env check-target
	sudo nixos-rebuild switch -I nixos-config=${TARGET} --upgrade

nixos.build-vm: check-env 
	sudo nixos-rebuild build-vm -I nixos-config=${HOSTS_PATH}/vm.nix
