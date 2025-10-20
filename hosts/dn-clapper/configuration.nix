{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-clapper";

  services.openssh.enable = true;

  # Zeroconf DNS
  services.avahi.enable = true;

  system.stateVersion = "25.05";
}
