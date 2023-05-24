#!/bin/sh

check-env:
ifeq ("${IN_NIX_SHELL}", "")
	$(error "Not in Nix shell")
endif

echo In Nix shell: ${IN_NIX_SHELL}

lint: check-env
	alejandra .

