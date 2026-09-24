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
    "sr_mod"
    "cdrom"
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

  # TODO: Rename this attr so that way it;s clearer this is special for non BIOS ARM machines
  # For ARM64 hosts with a device tree, GRUB needs to load the DTB using
  # the 'devicetree' command, and 'dtb=' must NOT be in kernel command line arguments
  # (as the kernel EFI stub cannot load a DTB from GRUB's memory-mapped image handle).
  system.build.installerIso = let
    baseIso = config.system.build.isoImage;

    extraFilesDtb = lib.findFirst
      (k: lib.hasSuffix ".dtb" k)
      null
      (lib.attrNames (config.boot.loader.systemd-boot.extraFiles or {}));

    deviceTreeDtb =
      if (config.hardware.deviceTree.enable or false) && ((config.hardware.deviceTree.name or null) != null)
      then "dtbs/${config.hardware.deviceTree.name}"
      else null;

    dtbRelPath =
      if extraFilesDtb != null then extraFilesDtb
      else deviceTreeDtb;

    pairs = lib.zipListsWith (target: source: { inherit target source; }) baseIso.targets baseIso.sources;
    origEfiPair = lib.findFirst (p: p.target == "/EFI") null pairs;
    origEfiImgPair = lib.findFirst (p: p.target == "/boot/efi.img") null pairs;

    patchedEfiDir = pkgs.runCommand "patched-efi-dir" {
      nativeBuildInputs = [ pkgs.buildPackages.gnused pkgs.grub2_efi ];
    } ''
      mkdir -p $out
      cp -rp "${origEfiPair.source}/." "$out/"
      chmod -R u+w "$out"

      # 1. Strip dtb= from grub.cfg so the Linux EFI stub does not attempt
      # to open a DTB from a non-existent EFI filesystem handle.
      sed -i -E 's/dtb=[^ ]+ //g; s/ dtb=[^ ]+//g' "$out/BOOT/grub.cfg"

      # 2. Add devicetree command right after each initrd line so GRUB installs
      # the FDT into the UEFI configuration table.
      sed -i -E '/^[[:space:]]*initrd[[:space:]]+/a\  devicetree ($root)/${dtbRelPath}' "$out/BOOT/grub.cfg"

      # 3. Validate grub syntax
      grub-script-check "$out/BOOT/grub.cfg"
    '';

    patchedEfiImg = pkgs.runCommand "patched-efi-img" {
      nativeBuildInputs = [ pkgs.buildPackages.mtools ];
    } ''
      cp "${origEfiImgPair.source}" "$out"
      chmod u+w "$out"
      mcopy -o -i "$out" "${patchedEfiDir}/BOOT/grub.cfg" "::/EFI/BOOT/grub.cfg"
    '';

    patchedSources = lib.zipListsWith (target: source:
      if target == "/EFI" then
        patchedEfiDir
      else if target == "/boot/efi.img" then
        patchedEfiImg
      else
        source
    ) baseIso.targets baseIso.sources;
  in
    if dtbRelPath != null && origEfiPair != null && origEfiImgPair != null
    then baseIso.overrideAttrs (_: { sources = patchedSources; })
    else baseIso;
}

