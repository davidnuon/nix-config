#!/bin/sh

echo Running the initial NixOS rebuild
exec sudo nixos-rebuild switch -I nixos-config=./configuration.nix

