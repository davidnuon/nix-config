{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../mixins/base
    ../../mixins/home
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "dn-thickbook";

  # Tailscale
  networking.firewall.checkReversePath = "loose";
  services.tailscale.enable = true;
}
