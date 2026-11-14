{
  config,
  pkgs,
  specialArgs,
  lib,
  ...
}: let
  cfg = config.mixins.desktop;
in {
  imports = [
    specialArgs.aerothemeplasma-nix.nixosModules.aerothemeplasma-nix
  ];

  options.mixins.desktop = {
    kde = {
      enable = lib.mkEnableOption "KDE Plasma 6 desktop";
    };

    aero = {
      enable = lib.mkEnableOption "Aero theme plasma";
    };

    flatpak = {
      enable = lib.mkEnableOption "Flatpak";
    };

    remote-desktop = {
      enable = lib.mkEnableOption "Remmina remote desktop";
    };
  };

  config = lib.mkMerge [
    # KDE
    (lib.mkIf cfg.kde.enable {
      services.displayManager.sddm.enable = lib.mkIf (!config.services.displayManager.gdm.enable) true;

      services.desktopManager.plasma6.enable = true;
      programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

      qt = {
        enable = true;
        platformTheme = "gnome";
        style = "adwaita-dark";
      };
      programs.dconf.enable = true;
    })

    # Aero
    (lib.mkIf cfg.aero.enable {
      services.displayManager.gdm.enable = lib.mkForce false;
      boot.plymouth.enable = true;
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;
      services.displayManager.defaultSession = "aerothemeplasma"; # for x11, append x11
      programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

      programs.aeroshell = {
        enable = true;
        fonts.segoe.enable = true;
        polkit.enable = true;
        aerothemeplasma = {
          enable = true;
          sddm.enable = true;
          plymouth.enable = true;
        };
      };
    })

    # Flatpak
    (lib.mkIf cfg.flatpak.enable {
      xdg.portal.enable = true;
      services.flatpak.enable = true;

      # Ensure the centralized font directory is created at /run/current-system/sw/share/X11/fonts
      fonts.fontDir.enable = true;

      # Expose host fonts and configure global Flatpak overrides so all Flatpak apps can read system and user fonts
      systemd.tmpfiles.rules = [
        "d /usr/share 0755 root root -"
        "L+ /usr/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
        "d /var/lib/flatpak/overrides 0755 root root -"
        "L+ /var/lib/flatpak/overrides/global - - - - ${pkgs.writeText "flatpak-global-overrides" ''
          [Context]
          filesystems=/nix/store:ro;/run/current-system/sw/share/X11/fonts:ro;xdg-data/fonts:ro;~/.local/share/fonts:ro;~/.icons:ro;
        ''}"
      ];

      systemd.services.flatpak-repo = {
        wantedBy = ["multi-user.target"];
        path = [pkgs.flatpak];
        script = ''
          flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        '';
      };
    })

    # Remote desktop
    (lib.mkIf cfg.remote-desktop.enable {
      environment.systemPackages = with pkgs; [
        remmina
      ];
    })
  ];
}
