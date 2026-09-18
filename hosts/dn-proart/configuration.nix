{
  lib,
  config,
  pkgs,
  ...
}: {
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-proart";
  services.fwupd.enable = true;

  system.stateVersion = "26.05"; # Did you read the comment?
}
