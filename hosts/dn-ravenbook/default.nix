{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../mixins/base
    ../../mixins/home
    ../../mixins/tailscale
    ../../mixins/flatpak
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "dn-ravenbook";
}
