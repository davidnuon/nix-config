{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    # ../../mixins/base
    # ../../mixins/home
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-silverbook";
  services.fwupd.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
