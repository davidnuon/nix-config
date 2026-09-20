{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  mixins.base.enable = true;
  mixins.kde.enable = true;
  mixins.docker.enable = true;
  mixins.tailscale.enable = true;
  mixins.flatpak.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-clapper";

  system.stateVersion = "25.05";
}
