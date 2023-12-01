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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "dn-jetbook";

  # Tailscale
  networking.firewall.checkReversePath = "loose";
  services.tailscale.enable = true;
}
