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
  nixos-x13s.kernel = "jhovold"; # jhovold is default, but mainline supported
  specialisation = {
    mainline.configuration.nixos-x13s.kernel = "jhovold";
  };

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "dn-blackleg";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  users.users.davidnuon = {
    isNormalUser = true;
    home = "/home/davidnuon";
    extraGroups = ["wheel" "networkManager"];
  };

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.displayManager.defaultSession = "gnome";

  services.avahi.enable = true;

  system.stateVersion = "24.11"; # Did you read the comment?
}
