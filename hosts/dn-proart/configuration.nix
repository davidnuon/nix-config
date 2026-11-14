{
  lib,
  config,
  pkgs,
  ...
}: {
  mixins = {
    base.enable = true;
    nix-infra.nixcache.client.enable = true;
    virtualization = {
      docker.enable = true;
      libvirt.enable = true;
    };
    desktop = {
      remote-desktop.enable = true;
      flatpak.enable = true;
    };
    system.tailscale.enable = true;
    tools.agy.enable = true;

    creative = {
      affinity.enable = true;
      artcraft.enable = true;
      libreoffice.enable = true;
      officecraft.enable = true;
      patchy.enable = true;
      photogimp.enable = true;
    };

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
