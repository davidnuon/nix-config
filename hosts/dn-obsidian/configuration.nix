# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  mixins.base.enable = true;
  mixins.docker.enable = true;
  mixins.tailscale.enable = true;
  mixins.flatpak.enable = true;
  mixins.xivlauncher.enable = true;
  mixins.steam.enable = true;
  mixins.lutris.enable = true;
  mixins.kde.enable = true;
  mixins.input-remapper.enable = true;
  mixins.distrobox.enable = true;
  mixins.forge-mtg.enable = true;
  mixins.virtualization.enable = true;
  mixins.godot.enable = true;
  mixins.affinity.enable = true;
  mixins.ts100-driver.enable = true;
  mixins.guix.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.enable = true;
  services.avahi.enable = true;

  networking.hostName = "dn-obsidian";

  programs.ssh.forwardX11 = true;
  services.openssh.settings.X11Forwarding = true;

  system.stateVersion = "25.11"; # Did you read the comment?
}
