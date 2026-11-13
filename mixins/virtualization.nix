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
      programs.virt-manager.enable = true;
      users.groups.libvirtd.members = ["davidnuon"];
      virtualisation.spiceUSBRedirection.enable = true;

      virtualisation.libvirtd.enable = true;
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
