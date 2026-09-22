{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hardware.wwan;
in {
  options.hardware.wwan = {
    enable = lib.mkEnableOption "WWAN / Cellular modem support for ThinkPad X13s";

    apn = lib.mkOption {
      type = lib.types.str;
      default = "fast.t-mobile.com";
      description = "Access Point Name (APN) for the cellular connection.";
    };

    connectionName = lib.mkOption {
      type = lib.types.str;
      default = "Cellular";
      description = "Name for the NetworkManager cellular connection profile.";
    };

    autoconnect = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically connect to cellular when the network is available.";
    };

    pin = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "SIM PIN code (if required by your SIM).";
    };

    fccUnlock = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable automatic FCC unlock for the WWAN modem.";
      };

      deviceId = lib.mkOption {
        type = lib.types.str;
        default = "105b:e0c3";
        description = "Modem vendor and product ID for FCC unlock (Foxconn T99W175 / SDX55 is 105b:e0c3).";
      };
    };

    allowUserControl = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow users in wheel and networkmanager groups to send DBus method calls and execute ModemManager actions without password prompts.";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [
        pkgs.modemmanager
        pkgs.libqmi
        pkgs.libmbim
      ];
      description = "Diagnostic and management CLI packages to install for WWAN.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure ModemManager is enabled
    networking.modemmanager.enable = true;

    # Automatic FCC unlock script for Foxconn T99W175
    networking.modemmanager.fccUnlockScripts = lib.mkIf cfg.fccUnlock.enable [
      {
        id = cfg.fccUnlock.deviceId;
        path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/105b";
      }
    ];

    # Declarative NetworkManager GSM Cellular profile
    networking.networkmanager.ensureProfiles.profiles = {
      "${cfg.connectionName}" = {
        connection = {
          id = cfg.connectionName;
          type = "gsm";
          autoconnect = cfg.autoconnect;
        };
        gsm = {
          apn = cfg.apn;
        } // lib.optionalAttrs (cfg.pin != null) {
          pin = cfg.pin;
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          method = "auto";
          addr-gen-mode = "default";
        };
      };
    };

    # Grant DBus access to networkmanager and wheel groups for ModemManager
    environment.etc = lib.mkIf cfg.allowUserControl {
      "dbus-1/system.d/99-modemmanager-user-control.conf".text = ''
        <!DOCTYPE busconfig PUBLIC
         "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
         "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
        <busconfig>
          <policy group="networkmanager">
            <allow send_destination="org.freedesktop.ModemManager1"/>
          </policy>
          <policy group="wheel">
            <allow send_destination="org.freedesktop.ModemManager1"/>
          </policy>
        </busconfig>
      '';
    };

    # Polkit authorization for ModemManager operations
    security.polkit.extraConfig = lib.mkIf cfg.allowUserControl ''
      polkit.addRule(function(action, subject) {
        if (
          (subject.isInGroup("networkmanager") || subject.isInGroup("wheel")) &&
          action.id.indexOf("org.freedesktop.ModemManager1.") == 0
        ) {
          return polkit.Result.YES;
        }
      });
    '';

    # Useful CLI tools for cellular diagnostics (mmcli, qmicli, mbimcli)
    environment.systemPackages = cfg.packages;
  };
}
