host?=$(shell hostname)
HOSTS_PATH=./hosts
TARGET=${host}

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
	sudo nixos-rebuild build --flake .#${TARGET}

nixos.dry-build: check-env check-target
	sudo nixos-rebuild dry-build --flake .#${TARGET}

nixos.switch: check-env check-target
	sudo nixos-rebuild switch --flake .#${TARGET}

nixos.upgrade: check-env check-target
	nix flake update
	sudo nixos-rebuild switch --flake .#${TARGET}

nixos.build-vm: check-env 
	sudo nixos-rebuild build-vm --flake .#${HOSTS_PATH}/vm.nix
