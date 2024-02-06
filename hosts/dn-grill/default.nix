{
  lib,
  config,
  pkgs,
  ...
}: let
  nixos-hardware = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixos-hardware/archive/83e571b.tar.gz";
    sha256 = "3bc1d2146788ef24a2c0a9ac72fae6214a7c4ab5ec7a100a5904a73427a87e09";
  };
in {
  imports = [
    "${nixos-hardware}/framework/13-inch/12th-gen-intel"
    ./hardware-configuration.nix
    (import ../../mixins/home/23.11.nix {version = "23.11";})
    ../../mixins/base-2311
    ../../mixins/virtualization
    ../../mixins/tailscale
    ../../mixins/flatpak
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-grill";
  services.openssh.enable = true;
  services.avahi.enable = true;

  time.timeZone = "America/Los_Angeles";

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  system.stateVersion = "23.11";
}
