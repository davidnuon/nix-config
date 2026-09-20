{
  lib,
  config,
  pkgs,
  ...
}: {
  mixins.kde.enable = true;
  mixins.steam.enable = true;
  mixins.base.enable = true;
  mixins.docker.enable = true;
  mixins.remote-desktop.enable = true;
  mixins.virtualization.enable = true;
  mixins.tailscale.enable = true;
  mixins.flatpak.enable = true;
  mixins.libreoffice.enable = true;
  mixins.godot.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-silverbook";
  services.fwupd.enable = true;

  system.stateVersion = "24.11"; # Did you read the comment?
}
