#!/bin/sh

exec sudo nixos-rebuild switch -I nixos-config=./configuration.nix

