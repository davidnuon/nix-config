{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixos-x13s.enable = true;
  nixos-x13s.kernel = "mainline"; # jhovold is default, but mainline supported
  # specialisation = {
  #   mainline.configuration.nixos-x13s.kernel = "jhovold";
  # };

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "dn-blackleg";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  users.users.davidnuon = {
    isNormalUser = true;
    home = "/home/davidnuon";
    extraGroups = ["wheel" "networkManager"];
  };

  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  services.avahi.enable = true;

  system.stateVersion = "25.11"; # Did you read the comment?
}
