{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  inherit (lib) mkDefault mkForce optionals;
  hostName = config.networking.hostName;
in {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
  ];

  # Naming and edition
  isoImage.edition = mkDefault hostName;
  isoImage.appendToMenuLabel = mkDefault " (${hostName} Installer)";
  # Volume ID can be at most 32 characters (ISO 9660 constraint)
  isoImage.volumeID = mkDefault (lib.substring 0 32 "NIXOS_${lib.toUpper (lib.replaceStrings ["-"] ["_"] hostName)}");

  # Avoid timeout conflicts (e.g. dn-chewy defines boot.loader.timeout = 3)
  boot.loader.timeout = mkForce 10;

  # Stage 1 Initrd robustness
  boot.initrd.systemd.emergencyAccess = mkDefault true;

  # Essential storage & filesystem modules for the live installer
  boot.initrd.kernelModules = [
    "squashfs"
    "iso9660"
    "overlay"
    "usb_storage"
    "uas"
  ];

  # Silence ZFS root import warning on modern nixpkgs
  boot.zfs.forceImportRoot = mkDefault false;

  # User & Authentication for Installer
  users.users.nixos = {
    initialHashedPassword = "";
    extraGroups = ["wheel" "networkmanager" "video"];
  };
  users.users.root.initialHashedPassword = "";

  # Ensure passwordless sudo
  security.sudo.wheelNeedsPassword = mkForce false;

  # If a graphical display manager (GDM/LightDM/SDDM) is enabled, autologin as nixos
  services.displayManager.autoLogin = {
    enable = mkDefault true;
    user = mkDefault "nixos";
  };

  # Essential tools for installation
  environment.systemPackages = with pkgs; [
    git
    vim
    parted
    efibootmgr
    disko
    curl
    rsync
  ];

  # Nix configuration
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["root" "nixos" "@wheel"];
  };

  # ARM / Device Tree Handling
  # Copy device tree blobs and any systemd-boot extraFiles to the ISO root and /boot
  # so that EFI stub / bootloaders can access them.
  isoImage.contents =
    (lib.concatLists (lib.mapAttrsToList (path: file: [
      {
        source = file;
        target = "/" + path;
      }
      {
        source = file;
        target = "/boot/" + path;
      }
    ]) (config.boot.loader.systemd-boot.extraFiles or {})))
    ++ optionals (config.hardware.deviceTree.enable or false) [
      {
        source = config.hardware.deviceTree.package;
        target = "/dtbs";
      }
      {
        source = config.hardware.deviceTree.package;
        target = "/boot/dtbs";
      }
    ];

  # Ensure dtb parameter is set in kernelParams if deviceTree.name is defined
  boot.kernelParams =
    optionals (
      (config.hardware.deviceTree.enable or false)
      && ((config.hardware.deviceTree.name or null) != null)
    ) [
      "dtb=dtbs/${config.hardware.deviceTree.name}"
    ];
}
