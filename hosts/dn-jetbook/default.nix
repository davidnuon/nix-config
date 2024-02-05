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
    ../../mixins/virtualization
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "dn-jetbook";

  system.stateVersion = "22.11";
}
