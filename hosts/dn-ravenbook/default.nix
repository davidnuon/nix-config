{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../mixins/base
    ../../mixins/home
    ../../mixins/tailscale
    ../../mixins/flatpak
    ../../mixins/libreoffice
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "dn-ravenbook";

  system.stateVersion = "23.05";
}
