# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.enable = true;
  services.avahi.enable = true;

  networking.hostName = "dn-obsidian";

  programs.ssh.forwardX11 = true;
  services.openssh.settings.X11Forwarding = true;

  system.stateVersion = "25.11"; # Did you read the comment?
}
