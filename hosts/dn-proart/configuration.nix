{
  lib,
  config,
  pkgs,
  ...
}: {
  mixins.steam.enable = true;
  mixins.base.enable = true;
  mixins.docker.enable = true;
  mixins.xivlauncher.enable = true;
  mixins.remote-desktop.enable = true;
  mixins.virtualization.enable = true;
  mixins.tailscale.enable = true;
  mixins.flatpak.enable = true;
  mixins.libreoffice.enable = true;
  mixins.godot.enable = true;
  mixins.agy.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.consoleMode = "2"; # or "0", "1", "2", "auto"
  boot.plymouth.enable = false;

  networking.hostName = "dn-proart";
  services.fwupd.enable = true;

  console = {
    earlySetup = true;
    packages = with pkgs; [terminus_font];
    font = "ter-v32n"; # or "ter-u28n" for a slightly smaller large option
  };

  system.stateVersion = "26.05"; # Did you read the comment?
}
