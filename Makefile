#!/bin/sh

check-env:
ifeq ("${IN_NIX_SHELL}", "")
	$(error "Not in Nix shell")
endif

echo In Nix shell: ${IN_NIX_SHELL}

lint: check-env
	alejandra .

nixos.build: check-env
	sudo nixos-rebuild build -I nixos-config=./configuration.nix

nixos.dry-build: check-env
	sudo nixos-rebuild dry-build -I nixos-config=./configuration.nix

nixos.switch: check-env
	sudo nixos-rebuild switch -I nixos-config=./configuration.nix

nixos.upgrade: check-env
	sudo nixos-rebuild switch -I nixos-config=./configuration.nix --upgrade

nixos.build-vm: check-env
	sudo nixos-rebuild build-vm -I nixos-config=./vm.nix
