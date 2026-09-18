{
  lib,
  config,
  pkgs,
  ...
}: {
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.consoleMode = "0"; # or "0", "1", "2", "auto"

  networking.hostName = "dn-proart";
  services.fwupd.enable = true;

  console = {
    earlySetup = true;
    packages = with pkgs; [terminus_font];
    font = "ter-v32n"; # or "ter-u28n" for a slightly smaller large option
  };

  system.stateVersion = "26.05"; # Did you read the comment?
}
