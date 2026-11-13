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
    docker.enable = true;
    agy.enable = true;
    tailscale.enable = true;
    flatpak.enable = true;
    kde.enable = true;
    input-remapper.enable = true;
    distrobox.enable = true;
    virtualization.enable = true;
    nixcache.enable = true;
    buildbot.enable = true;
    remote-builder.client.enable = true;

    gaming = {
      xivlauncher.enable = true;
      steam.enable = true;
      forge-mtg.enable = true;
    };
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.enable = true;
  services.avahi.enable = true;

  networking.hostName = "dn-mememobile";

  programs.ssh.forwardX11 = true;
  services.openssh.settings.X11Forwarding = true;

  system.stateVersion = "25.11"; # Did you read the comment?

  # Disable laptop sleepy behavior
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
