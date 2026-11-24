{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.mixins.virtualization;
in {
  options.mixins.virtualization = {
    docker = {
      enable = lib.mkEnableOption "Docker";
    };
    distrobox = {
      enable = lib.mkEnableOption "Distrobox";
    };
    libvirt = {
      enable = lib.mkEnableOption "libvirt / virt-manager";
    };
    virtualbox = {
      enable = lib.mkEnableOption "VirtualBox";
    };
    waydroid = {
      enable = lib.mkEnableOption "Waydroid";
    };
  };

  config = lib.mkMerge [
    # Docker
    (lib.mkIf cfg.docker.enable {
      virtualisation.docker.enable = true;
    })

    # Distrobox
    (lib.mkIf cfg.distrobox.enable {
      environment.systemPackages = [pkgs.distrobox];
    })

    # libvirt / virt-manager
    (lib.mkIf cfg.libvirt.enable {
      hardware.graphics.enable = lib.mkDefault true;

      programs.virt-manager.enable = true;
      users.groups.libvirtd.members = ["davidnuon"];
      virtualisation.spiceUSBRedirection.enable = true;

      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
          vhostUserPackages = [
            config.virtualisation.libvirtd.qemu.package
            pkgs.virtiofsd
          ];
          verbatimConfig = let
            deviceAcl =
              [
                "/dev/null"
                "/dev/full"
                "/dev/zero"
                "/dev/random"
                "/dev/urandom"
                "/dev/ptmx"
                "/dev/userfaultfd"
                "/dev/udmabuf"
                "/dev/dri/renderD128"
                "/dev/dri/renderD129"
              ]
              ++ lib.optionals config.hardware.nvidia.enabled [
                "/dev/nvidiactl"
                "/dev/nvidia0"
                "/dev/nvidia1"
                "/dev/nvidia-modeset"
                "/dev/nvidia-uvm"
                "/dev/nvidia-uvm-tools"
              ];
          in ''
            namespaces = []
            cgroup_device_acl = [
              ${lib.concatMapStringsSep ",\n  " (d: ''"${d}"'') deviceAcl}
            ]
          '';
        };
      };
      programs.dconf.enable = true; # virt-manager requires dconf to remember settings
      environment.systemPackages = with pkgs; [
        virt-manager
        virt-top
        pkgs.gnome-boxes
      ];
    })

    # VirtualBox
    (lib.mkIf cfg.virtualbox.enable {
      virtualisation.virtualbox.host.enable = true;
      virtualisation.virtualbox.guest.enable = true;
    })

    # Waydroid
    (lib.mkIf cfg.waydroid.enable {
      virtualisation.waydroid.enable = true;
    })
  ];
}
