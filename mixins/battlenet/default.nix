{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  cfg = config.programs.battlenet;
  system = pkgs.stdenv.hostPlatform.system;
  unstable-pkgs = import specialArgs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  imports = [
    (lib.mkAliasOptionModule ["programs" "battle-net"] ["programs" "battlenet"])
  ];

  options.programs.battlenet = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Battle.net.";
    };

    protonPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.proton-ge-bin;
      description = "Proton compatibility tool to use with Battle.net (e.g. pkgs.proton-ge-bin).";
    };

    umuPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.umu-launcher.override {
        umu-launcher-unwrapped = unstable-pkgs.umu-launcher-unwrapped;
        # buildFHSEnv's /etc/profile exports TZ=<IANA zone> (e.g. TZ=America/Los_Angeles).
        # Wine copies TZ into the Windows environment block, where Microsoft's UCRT (_tzset)
        # only understands legacy 3-letter POSIX TZ strings and misparses IANA names as UTC.
        # Unsetting TZ lets glibc/Wine read /etc/localtime and Windows CRT use GetTimeZoneInformation().
        extraProfile = ''
          unset TZ
        '';
      };
      description = "umu-launcher package to use with Battle.net.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        WINE_SIMULATE_WRITECOPY = "1";
      };
      description = "Extra environment variables passed to Battle.net via nix-battle-net.env.";
    };

    enableControllerSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to configure hardware rules, uinput, and Proton environment variables for controller support.";
    };

    enableXboxWireless = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the xpadneo kernel module for Xbox wireless controllers over Bluetooth.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = let
        controllerEnv = lib.optionalAttrs cfg.enableControllerSupport {
          PROTON_SONY_HIDRAW_XINPUT = "1";
          PROTON_ENABLE_HIDRAW = "1";
          PROTON_PREFER_SDL = "1";
          SDL_JOYSTICK_HIDAPI = "1";
        };
        bnet = specialArgs.nix-battle-net.packages.${system}.battle-net or pkgs.emptyDirectory;
      in
        if bnet ? override
        then
          bnet.override (lib.filterAttrs (_: v: v != null) {
            protonVersion = cfg.protonPackage;
            umu-launcher = cfg.umuPackage;
            environment = controllerEnv // cfg.environment;
          })
        else bnet;
      description = "Battle.net package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = specialArgs.nix-battle-net.packages ? ${system}.battle-net;
        message = "nix-battle-net does not support system ${system}.";
      }
    ];

    hardware.steam-hardware.enable = lib.mkIf cfg.enableControllerSupport (lib.mkDefault true);
    hardware.uinput.enable = lib.mkIf cfg.enableControllerSupport (lib.mkDefault true);
    boot.kernelModules = lib.mkIf cfg.enableControllerSupport ["uinput"];
    hardware.xpadneo.enable = lib.mkIf cfg.enableXboxWireless (lib.mkDefault true);

    nixpkgs.overlays = [
      (_final: _prev: {
        battle-net = cfg.package;
      })
    ];

    environment.systemPackages = [
      cfg.package
    ];

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "battle-net"
      ];
  };
}
