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

update:
	nix flake update

nixos.install: check-env check-target
	sudo nixos-install --flake .#${TARGET}
	echo "Don't forget to run sudo nixos-enter to assign a password to davidnuon!"

nixos.install-lan: check-env check-target
	sudo nixos-install --flake .#${TARGET} \ 
		--option extra-substituters 'http://10.0.0.12:5000' \ 
		--option extra-trusted-public-keys 'dn-mememobile-1:WltXjnqq31qus5i6nkhMsk5OCcRbwFM1VwJ7kLmFSQg='
	echo "Don't forget to run sudo nixos-enter to assign a password to davidnuon!"

nixos.run-disko: check-env check-target
	sudo disko --mode destroy,format,mount ./hosts/${TARGET}/disk-config.nix

nixos.build: check-env check-target
	sudo nixos-rebuild build --flake .#${TARGET}

nixos.build-all-x86: check-env
	nix build .#all-x86

hydra.trigger-x86:
	curl -f -s -X POST 'http://localhost:3000/api/push?jobsets=nix-config:x86-hosts&force=1' -H 'Origin: http://localhost:3000'
	@echo "Hydra x86-hosts build job triggered!"

nixos.dry-build: check-env check-target
	sudo nixos-rebuild dry-build --flake .#${TARGET}

nixos.switch: check-env check-target
	sudo nixos-rebuild switch --flake .#${TARGET}

nixos.test: check-env check-target
	sudo nixos-rebuild test --flake .#${TARGET}

nixos.boot: check-env check-target
	sudo nixos-rebuild boot --flake .#${TARGET}

nixos.upgrade: check-env check-target update nixos.build
	sudo nixos-rebuild switch --flake .#${TARGET}

nixos.build-vm: check-env 
	sudo nixos-rebuild build-vm --flake .#${HOSTS_PATH}/vm.nix

iso.blackleg: check-env
	nix build .#dn-blackleg-iso

iso.microwave: check-env
	nix build .#dn-microwave-iso

vhd.blackleg: check-env
	nix build .#dn-blackleg-vhd

vhd.microwave: check-env
	nix build .#dn-microwave-vhd

iso.installer: check-env
	nix build .#dn-installer-iso

vhd.installer: check-env
	nix build .#dn-installer-vhd
