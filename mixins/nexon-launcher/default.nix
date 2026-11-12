{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  cfg = config.programs.nexon-launcher;
  system = pkgs.stdenv.hostPlatform.system;
  unstable-pkgs = import specialArgs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  imports = [
    (lib.mkAliasOptionModule ["programs" "nexon"] ["programs" "nexon-launcher"])
  ];

  options.programs.nexon-launcher = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Nexon Launcher (with MapleStory compatibility fixes).";
    };

    protonPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      # GE-Proton11-3+ (unstable-pkgs has GE-Proton11-11) includes upstream fixes for
      # MapleStory's 0xc0000005 kernelbase CharPrevExA launch crash (PR #603) and
      # win32u SPI_SETSTICKYKEYS/SPI_SETFILTERKEYS accessibility calls (PR #601).
      default = unstable-pkgs.proton-ge-bin;
      defaultText = lib.literalExpression "unstable-pkgs.proton-ge-bin";
      description = "Proton compatibility tool to use with Nexon Launcher (needs GE-Proton11-3+ for MapleStory).";
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
      defaultText = lib.literalExpression "pkgs.umu-launcher.override { umu-launcher-unwrapped = unstable-pkgs.umu-launcher-unwrapped; ... }";
      description = "umu-launcher package to use with Nexon Launcher.";
    };

    virtualDesktop = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "1920x1080";
      description = "Optional Wine virtual desktop resolution (e.g. \"1920x1080\") to work around XWayland BadWindow crashes.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        WINE_SIMULATE_WRITECOPY = "1";
      };
      description = "Extra environment variables passed to Nexon Launcher via nix-nexon-launcher.env.";
    };

    enableControllerSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to configure hardware rules, uinput (and 'input' group membership for MapleStory DirectInput8 skill keys), and Proton controller variables.";
    };

    enableXboxWireless = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the xpadneo kernel module for Xbox wireless controllers over Bluetooth.";
    };

    fixAppleFnMode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to set hid_apple fnmode=2 so F1-F12 keys reach MapleStory instead of media keys on Apple-compatible keyboards.";
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
      in
        pkgs.callPackage ./package.nix {
          protonVersion = cfg.protonPackage;
          umu-launcher = cfg.umuPackage;
          virtualDesktop = cfg.virtualDesktop;
          environment = controllerEnv // cfg.environment;
        };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { ... }";
      description = "Nexon Launcher package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = system == "x86_64-linux";
        message = "nexon-launcher only supports x86_64-linux (current system: ${system}).";
      }
    ];

    hardware.steam-hardware.enable = lib.mkIf cfg.enableControllerSupport (lib.mkDefault true);
    hardware.uinput.enable = lib.mkIf cfg.enableControllerSupport (lib.mkDefault true);
    boot.kernelModules = lib.mkIf cfg.enableControllerSupport ["uinput"];
    hardware.xpadneo.enable = lib.mkIf cfg.enableXboxWireless (lib.mkDefault true);

    boot.extraModprobeConfig = lib.mkIf cfg.fixAppleFnMode ''
      options hid_apple fnmode=2
    '';

    # Also register GE-Proton11-11 into Steam's extraCompatPackages if Steam is enabled
    # so MapleStory works via Steam as well.
    programs.steam.extraCompatPackages = lib.mkIf (config.programs.steam.enable && cfg.protonPackage != null) [
      cfg.protonPackage
    ];

    nixpkgs.overlays = [
      (_final: _prev: {
        nexon-launcher = cfg.package;
      })
    ];

    environment.systemPackages = [
      cfg.package
    ];

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "nexon-launcher"
        "proton-ge-bin"
      ];
  };
}
