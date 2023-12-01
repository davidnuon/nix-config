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
    "${nixos-hardware}/framework/13-inch/12th-gen-intel"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "dn-grill";

  # Tailscale
  networking.firewall.checkReversePath = "loose";
  services.tailscale.enable = true;
}
