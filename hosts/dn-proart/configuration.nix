{
  lib,
  config,
  pkgs,
  ...
}: {
  mixins = {
    base.enable = true;
    nixcache.client.enable = true;
    docker.enable = true;
    remote-desktop.enable = true;
    virtualization.enable = true;
    flatpak.enable = true;
    tailscale.enable = true;
    artcraft.enable = true;
    patchy.enable = true;
    affinity.enable = true;
    officecraft.enable = true;
    photogimp.enable = true;
    libreoffice.enable = true;
    agy.enable = true;

    gaming = {
      lutris.enable = true;
      battlenet.enable = true;
      steam.enable = true;
      forge-mtg.enable = true;
      xivlauncher.enable = true;
      godot.enable = true;
    };
  };
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

  programs.forge-mtg.useHead = true;

  system.stateVersion = "26.05"; # Did you read the comment?
}
