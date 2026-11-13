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
    nix-infra.nixcache.client.enable = true;
    desktop = {
      kde.enable = true;
      flatpak.enable = true;
    };
    virtualization.docker.enable = true;
    system.tailscale.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-clapper";

  system.stateVersion = "25.05";
}
