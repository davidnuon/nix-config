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
    docker.enable = true;
    tailscale.enable = true;
    flatpak.enable = true;
    virtualization.enable = true;

    gaming.forge-mtg.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "dn-jetbook";

  system.stateVersion = "24.05";
}
