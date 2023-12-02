{
  lib,
  config,
  pkgs,
  ...
}: let
  nixos-hardware = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
  };
in {
  imports = [
    "${nixos-hardware}/framework/13-inch/7040-amd"
    ../../mixins/base
    ../../mixins/home
    ../../mixins/virtualization
    ../../mixins/tailscale
    ../../mixins/flatpak
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-silverbook";
}
