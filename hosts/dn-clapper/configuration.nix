{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  mixins = {
    base.enable = true;
    nixcache.client.enable = true;
    kde.enable = true;
    docker.enable = true;
    tailscale.enable = true;
    flatpak.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-clapper";

  system.stateVersion = "25.05";
}
