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
    tools = {
      agy.enable = true;
      guix.enable = true;
    };
    hardware.ts100-driver.enable = true;
    virtualization = {
      docker.enable = true;
      distrobox.enable = true;
      libvirt.enable = true;
    };
    desktop = {
      kde.enable = true;
      flatpak.enable = true;
    };
    system.tailscale.enable = true;
    nix-infra.nixcache.client.enable = true;

    creative = {
      affinity.enable = true;
      artcraft.enable = true;
      officecraft.enable = true;
      patchy.enable = true;
    };

    gaming = {
      battlenet.enable = true;
      nexon-launcher.enable = true;
      xivlauncher.enable = true;
      steam.enable = true;
      lutris.enable = true;
      forge-mtg.enable = true;
      godot.enable = true;
      input-remapper.enable = true;
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
