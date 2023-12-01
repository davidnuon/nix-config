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
    ../../mixins/base
    ../../mixins/home
    ../../mixins/virtualization
    "${nixos-hardware}/framework/13-inch/7040-amd"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-silverbook";

  # Tailscale
  networking.firewall.checkReversePath = "loose";
  services.tailscale.enable = true;

  services.flatpak.enable = true;
}
