# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  mixins = {
    base.enable = true;
    patchy.enable = true;
    agy.enable = true;
    docker.enable = true;
    tailscale.enable = true;
    flatpak.enable = true;
    kde.enable = true;
    nixcache.client.enable = true;
    input-remapper.enable = true;
    distrobox.enable = true;
    virtualization.enable = true;
    affinity.enable = true;
    artcraft.enable = true;
    officecraft.enable = true;
    ts100-driver.enable = true;
    guix.enable = true;

    gaming = {
      battlenet.enable = true;
      nexon-launcher.enable = true;
      xivlauncher.enable = true;
      steam.enable = true;
      lutris.enable = true;
      forge-mtg.enable = true;
      godot.enable = true;
    };
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.enable = true;
  services.avahi.enable = true;

  networking.hostName = "dn-obsidian";

  programs.ssh.forwardX11 = true;
  services.openssh.settings.X11Forwarding = true;

  system.stateVersion = "25.11"; # Did you read the comment?
}
