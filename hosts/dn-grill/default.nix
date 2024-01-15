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
    "${nixos-hardware}/framework/13-inch/12th-gen-intel"
    ./hardware-configuration.nix
    ../../mixins/base-2311
    ../../mixins/home-2311
    ../../mixins/virtualization
    ../../mixins/tailscale
    ../../mixins/flatpak
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-grill";
  services.openssh.enable = true;
  services.avahi.enable = true;

  system.stateVersion = "23.11";
}
