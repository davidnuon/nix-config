{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./base
    ./home
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-silverbook";

  # Tailscale
  networking.firewall.checkReversePath = "loose";
  services.tailscale.enable = true;
}
