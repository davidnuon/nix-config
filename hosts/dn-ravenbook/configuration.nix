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
    aero.enable = true;
    docker.enable = true;
    tailscale.enable = true;
    flatpak.enable = true;
    guix.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "dn-ravenbook";

  system.stateVersion = "23.11";
}
