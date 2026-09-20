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
  mixins.aero.enable = true;
  mixins.docker.enable = true;
  mixins.tailscale.enable = true;
  mixins.flatpak.enable = true;
  mixins.guix.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "dn-ravenbook";

  system.stateVersion = "23.11";
}
