{
  lib,
  config,
  pkgs,
  ...
}: {
  mixins = {
    base.enable = true;
    nixcache.client.enable = true;
    kde.enable = true;
    docker.enable = true;
    remote-desktop.enable = true;
    virtualization.enable = true;
    tailscale.enable = true;
    flatpak.enable = true;
    libreoffice.enable = true;

    gaming = {
      steam.enable = true;
      godot.enable = true;
    };
  };
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-silverbook";
  services.fwupd.enable = true;

  system.stateVersion = "24.11"; # Did you read the comment?
}
