{
  lib,
  config,
  pkgs,
  ...
}: let
  nixos-hardware = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixos-hardware/archive/83e571b.tar.gz";
    sha256 = "3bc1d2146788ef24a2c0a9ac72fae6214a7c4ab5ec7a100a5904a73427a87e09";
  };
in {
  imports = [
    "${nixos-hardware}/framework/13-inch/7040-amd"
    ./hardware-configuration.nix
    ../../mixins/base
    ../../mixins/home
    ../../mixins/virtualization
    ../../mixins/tailscale
    ../../mixins/flatpak
    ../../mixins/libreoffice
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-silverbook";

  system.stateVersion = "23.05"; # Did you read the comment?
}
