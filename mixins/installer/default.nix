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
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Naming and edition
  isoImage.edition = mkForce "${hostName}-minimal";
  isoImage.appendToMenuLabel = mkForce " (${hostName} Minimal Installer)";
  # Volume ID can be at most 32 characters (ISO 9660 constraint)
  isoImage.volumeID = mkDefault (lib.substring 0 32 "NIXOS_${lib.toUpper (lib.replaceStrings ["-"] ["_"] hostName)}");

  # Highest compression for squashfs to minimize ramdisk footprint and download size
  isoImage.squashfsCompression = mkDefault "zstd -Xcompression-level 19";

  # Hardware boot timeout
  boot.loader.timeout = mkForce 10;
  boot.loader.systemd-boot.enable = mkForce false;
  boot.loader.grub.enable = mkForce false;

  # Prevent installer from attempting to resume from target host swap partitions
  boot.resumeDevice = mkForce "";

  # Silence ZFS root import warning on modern nixpkgs
  boot.zfs.forceImportRoot = mkDefault false;

  # Stage 1 Initrd robustness
  boot.initrd.systemd.emergencyAccess = mkDefault true;

  # Essential storage, USB, & filesystem modules for finicky hardware and iODD ST300.
  # Note: 'uas' (USB Attached SCSI) is intentionally excluded and blacklisted below
  # because Qualcomm Snapdragon (SC8280XP) and many USB virtual optical drive bridges (like iODD)
  # suffer from command timeouts and dropped blocks under concurrent SquashFS reads.
  # Falling back to standard 'usb_storage' (Bulk-Only Transport) ensures rock-solid stability.
  boot.initrd.availableKernelModules = [
    "nvme"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    "ahci"
    "xhci_pci"
    "ehci_pci"
  ];
  boot.initrd.kernelModules = [
    "squashfs"
    "iso9660"
    "overlay"
    "usb_storage"
    "sr_mod"
    "cdrom"
  ];

  # Enable copytoram by default: loads the 1.5GB ISO into a RAM tmpfs during stage 1.
  # On 16GB+ RAM machines (like X13s and Dev Kit), this completely eliminates
  # USB read timeouts, dropped blocks, and squashfs I/O errors caused by USB link latency.
  boot.kernelParams = [
    "copytoram"
    "usbcore.autosuspend=-1"
  ];

  # Force single-threaded read-only mounting for squashfs and the ISO filesystem.
  # This prevents iODD ST300 virtual optical drive buffer overruns and dropped blocks
  # caused by multithreaded concurrent reads ('threads=multi').
  fileSystems = lib.mkForce {
    "/" = {
      fsType = "tmpfs";
      options = ["mode=0755"];
    };
    "/iso" = {
      device =
        if config.boot.initrd.systemd.enable
        then "/dev/disk/by-label/${config.isoImage.volumeID}"
        else "/dev/root";
      fsType = "iso9660";
      neededForBoot = true;
      noCheck = true;
      options = ["ro"];
    };
    "/nix/.ro-store" = {
      fsType = "squashfs";
      device = "${lib.optionalString config.boot.initrd.systemd.enable "/sysroot"}/iso/nix-store.squashfs";
      options = ["loop" "ro"];
      neededForBoot = true;
    };
    "/nix/.rw-store" = {
      fsType = "tmpfs";
      neededForBoot = true;
      options = ["mode=0755"];
    };
    "/nix/store" = {
      overlay = {
        lowerdir = ["/nix/.ro-store"];
        upperdir = "/nix/.rw-store/store";
        workdir = "/nix/.rw-store/work";
      };
    };
  };

  # Swap and LUKS reset for installer media
  swapDevices = lib.mkForce [];
  boot.initrd.luks.devices = lib.mkForce {};

  # Enable all firmware and hardware support
  hardware.enableAllHardware = mkDefault true;

  # In-memory compressed swap (zram) to prevent OOM panics
  zramSwap = {
    enable = mkDefault true;
    algorithm = mkDefault "zstd";
    memoryPercent = mkDefault 50;
  };

  # User & Authentication for Installer
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "video" "disk" "audio"];
    initialHashedPassword = "";
  };
  users.users.root.initialHashedPassword = "";

  # Ensure passwordless sudo & polkit permissions for installer user
  security.sudo.wheelNeedsPassword = mkForce false;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # Installer packages: disk partitioning, nix tools, hardware diagnostics
  environment.systemPackages = with pkgs; [
    # Installation & Nix tools
    git
    vim
    nano
    disko
    rsync
    curl
    wget

    # Hardware & Firmware debugging
    pciutils
    usbutils
    efibootmgr
    nvme-cli
    smartmontools
    dtc

    # Disk & Filesystem diagnostics / partitioning
    parted
    gptfdisk
    dosfstools
    e2fsprogs
    xfsprogs
    btrfs-progs
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

  # For ARM64 hosts with a device tree, GRUB needs to load the DTB using
  # the 'devicetree' command, and 'dtb=' must NOT be in kernel command line arguments
  # (as the kernel EFI stub cannot load a DTB from GRUB's memory-mapped image handle).
  system.build.installerIso = let
    baseIso = config.system.build.isoImage;

    extraFilesDtb =
      lib.findFirst
      (k: lib.hasSuffix ".dtb" k)
      null
      (lib.attrNames (config.boot.loader.systemd-boot.extraFiles or {}));

    deviceTreeDtb =
      if (config.hardware.deviceTree.enable or false) && ((config.hardware.deviceTree.name or null) != null)
      then "dtbs/${config.hardware.deviceTree.name}"
      else null;

    dtbRelPath =
      if extraFilesDtb != null
      then extraFilesDtb
      else deviceTreeDtb;

    pairs = lib.zipListsWith (target: source: {inherit target source;}) baseIso.targets baseIso.sources;
    origEfiPair = lib.findFirst (p: p.target == "/EFI") null pairs;
    origEfiImgPair = lib.findFirst (p: p.target == "/boot/efi.img") null pairs;

    patchedEfiDir =
      pkgs.runCommand "patched-efi-dir" {
        nativeBuildInputs = [pkgs.buildPackages.gnused pkgs.grub2_efi];
      } ''
        mkdir -p $out
        cp -rp "${origEfiPair.source}/." "$out/"
        chmod -R u+w "$out"

        # 1. Strip dtb= from grub.cfg so the Linux EFI stub does not attempt
        # to open a DTB from a non-existent EFI filesystem handle.
        sed -i -E 's/(^|[[:space:]])dtb=[^[:space:]]+//g' "$out/BOOT/grub.cfg"

        # 2. Add devicetree command right after each initrd line so GRUB installs
        # the FDT into the UEFI configuration table.
        sed -i -E '/^[[:space:]]*initrd[[:space:]]+/a\  devicetree ($root)/${dtbRelPath}' "$out/BOOT/grub.cfg"

        # 3. Validate grub syntax
        grub-script-check "$out/BOOT/grub.cfg"
      '';

    patchedEfiImg =
      pkgs.runCommand "patched-efi-img" {
        nativeBuildInputs = [pkgs.buildPackages.mtools];
      } ''
        cp "${origEfiImgPair.source}" "$out"
        chmod u+w "$out"
        mcopy -o -i "$out" "${patchedEfiDir}/BOOT/grub.cfg" "::/EFI/BOOT/grub.cfg"
      '';

    patchedSources =
      lib.zipListsWith (
        target: source:
          if target == "/EFI"
          then patchedEfiDir
          else if target == "/boot/efi.img"
          then patchedEfiImg
          else source
      )
      baseIso.targets
      baseIso.sources;

    # Patch make-iso9660-image.sh to enable GPT hybrid partitioning for EFI on ARM64.
    # By default, nixpkgs only passes -isohybrid-gpt-basdat which xorriso ignores
    # unless -isohybrid-mbr is present (x86 only). Replacing it with
    # '-efi-boot-part --efi-boot-image' forces xorriso to generate a valid GPT
    # partition table with an EFI System Partition, enabling direct USB booting via 'dd'.
    patchedBuildScript =
      pkgs.runCommand "patched-make-iso9660-image.sh" {
        nativeBuildInputs = [pkgs.buildPackages.gnused];
      } ''
        cp "${baseIso.buildCommandPath}" "$out"
        chmod u+w "$out"
        sed -i -E 's/-isohybrid-gpt-basdat/-efi-boot-part --efi-boot-image/g' "$out"
      '';
  in
    baseIso.overrideAttrs (_: {
      sources =
        if dtbRelPath != null && origEfiPair != null && origEfiImgPair != null
        then patchedSources
        else baseIso.sources;
      buildCommandPath = patchedBuildScript;
    });

  system.build.installerVhd = let
    baseIso = config.system.build.installerIso;
    hostName = config.networking.hostName;
  in
    pkgs.runCommand "nixos-${hostName}-minimal-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.vhd" {
      nativeBuildInputs = [pkgs.buildPackages.qemu-utils];
    } ''
      mkdir -p $out/vhd
      isoFile="$(echo ${baseIso}/iso/*.iso)"
      vhdName="$(basename "$isoFile" .iso).vhd"
      echo "Converting $isoFile to fixed VHD for iODD: $vhdName"
      qemu-img convert -f raw -O vpc -o subformat=fixed,force_size=on "$isoFile" "$out/vhd/$vhdName"
    '';

  system.build.vhd = config.system.build.installerVhd;
}
