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
      aero.enable = true;
      flatpak.enable = true;
    };
    virtualization.docker.enable = true;
    system.tailscale.enable = true;
    tools.guix.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "dn-ravenbook";

  system.stateVersion = "23.11";
}
