{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  mixins = {
    base.enable = true;
    nix-infra.nixcache.client.enable = true;
    virtualization.docker.enable = true;
    system.tailscale.enable = true;
    desktop.flatpak.enable = true;
    creative.affinity.enable = true;
    hardware.ts100-driver.enable = true;

    gaming = {
      battlenet.enable = true;
      steam.enable = true;
      lutris.enable = true;
    };
  };

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.timeout = 3;
  boot.loader.grub.extraConfig = ''

    export GRUB_FB_ROTATION=270
    GRUB_FB_ROTATION=270
    set rotation=270

  '';
  boot.loader.grub.device = "nodev";
  # boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  # chuwi Bootloader
  boot.loader.grub.gfxmodeEfi = "1200x1920x32";
  boot.loader.grub.gfxpayloadEfi = "keep";
  # more Bootloader
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-chewy";

  system.stateVersion = "26.05";
}
