{
  lib,
  config,
  pkgs,
  ...
}: {
  mixins = {
    base.enable = true;
    nix-infra.nixcache.client.enable = true;
    virtualization = {
      docker.enable = true;
      libvirt.enable = true;
    };
    desktop = {
      kde.enable = true;
      remote-desktop.enable = true;
      flatpak.enable = true;
    };
    system.tailscale.enable = true;
    creative.libreoffice.enable = true;

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
