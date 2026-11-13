{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  cfg = config.mixins.gaming;

  # --- Battle.net setup ---
  bnetCfg = config.programs.battlenet;
  system = pkgs.stdenv.hostPlatform.system;
  unstable-pkgs = import specialArgs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  # --- Forge MTG setup ---
  forge-src = specialArgs.forge or specialArgs.forge-src or null;
  forgeCfg = config.programs.forge-mtg;
  forge-git =
    if forge-src == null
    then throw "forge input is not provided in flake inputs"
    else
      (unstable-pkgs.forge-mtg.overrideMavenAttrs (old: {
        pname = "forge-mtg";
        version = "unstable-${forge-src.shortRev or "latest"}";
        src = forge-src;
        mvnHash = forgeCfg.mvnHash;
        installPhase = builtins.replaceStrings ["-${old.version}-"] ["-*-"] old.installPhase;
      }));
in {
  imports = [
    # Top-level backwards compatibility aliases
    (lib.mkAliasOptionModule ["mixins" "steam"] ["mixins" "gaming" "steam"])
    (lib.mkAliasOptionModule ["mixins" "lutris"] ["mixins" "gaming" "lutris"])
    (lib.mkAliasOptionModule ["mixins" "battlenet"] ["mixins" "gaming" "battlenet"])
    (lib.mkAliasOptionModule ["mixins" "battle-net"] ["mixins" "gaming" "battlenet"])
    (lib.mkAliasOptionModule ["mixins" "gaming" "battle-net"] ["mixins" "gaming" "battlenet"])
    (lib.mkAliasOptionModule ["mixins" "xivlauncher"] ["mixins" "gaming" "xivlauncher"])
    (lib.mkAliasOptionModule ["mixins" "forge-mtg"] ["mixins" "gaming" "forge-mtg"])
    (lib.mkAliasOptionModule ["mixins" "forge"] ["mixins" "gaming" "forge-mtg"])
    (lib.mkAliasOptionModule ["mixins" "gaming" "forge"] ["mixins" "gaming" "forge-mtg"])
    (lib.mkAliasOptionModule ["mixins" "nexon-launcher"] ["mixins" "gaming" "nexon-launcher"])
    (lib.mkAliasOptionModule ["mixins" "nexon"] ["mixins" "gaming" "nexon-launcher"])
    (lib.mkAliasOptionModule ["mixins" "gaming" "nexon"] ["mixins" "gaming" "nexon-launcher"])
    (lib.mkAliasOptionModule ["mixins" "godot"] ["mixins" "gaming" "godot"])
    (lib.mkAliasOptionModule ["mixins" "sunshine"] ["mixins" "gaming" "sunshine"])

    # Battle.net program alias
    (lib.mkAliasOptionModule ["programs" "battle-net"] ["programs" "battlenet"])
  ];

  options.mixins.gaming = {
    steam = {
      enable = lib.mkEnableOption "Steam";
    };
    lutris = {
      enable = lib.mkEnableOption "Lutris and ProtonPlus";
    };
    xivlauncher = {
      enable = lib.mkEnableOption "XIVLauncher for FFXIV";
    };
    godot = {
      enable = lib.mkEnableOption "Godot Game Engine";
    };
    sunshine = {
      enable = lib.mkEnableOption "Sunshine game streaming server";
    };
    nexon-launcher = {
      enable = lib.mkEnableOption "Nexon Launcher";
    };

    battlenet = {
      enable = lib.mkEnableOption "Battle.net";
    };

    forge-mtg = {
      enable = lib.mkEnableOption "Forge MTG";
    };
  };

  # Program options preserved for backwards compatibility and fine-tuning:
  options.programs.battlenet = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.battlenet.enable;
      description = "Whether to enable Battle.net.";
    };

    protonPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.proton-ge-bin;
      description = "Proton compatibility tool to use with Battle.net.";
    };

    umuPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.umu-launcher.override {
        umu-launcher-unwrapped = unstable-pkgs.umu-launcher-unwrapped;
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
      description = "Extra environment variables passed to Battle.net.";
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
        controllerEnv = lib.optionalAttrs bnetCfg.enableControllerSupport {
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
            protonVersion = bnetCfg.protonPackage;
            umu-launcher = bnetCfg.umuPackage;
            environment = controllerEnv // bnetCfg.environment;
          })
        else bnet;
      description = "Battle.net package to install.";
    };
  };

  options.programs.forge-mtg = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.forge-mtg.enable;
      description = "Whether to install Forge MTG.";
    };

    useHead = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use the HEAD build for Forge pinned via flake input.";
    };

    mvnHash = lib.mkOption {
      type = lib.types.str;
      default = "sha256-Dek7HJ89eOx7Yu+X76uAddyd2v7Y0Lre767F5gWTuIY=";
      description = "Maven dependencies output hash when building Forge from source.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default =
        if forgeCfg.useHead
        then forge-git
        else unstable-pkgs.forge-mtg;
      defaultText = lib.literalExpression "if config.programs.forge-mtg.useHead then <forge-git> else unstable-pkgs.forge-mtg";
      description = "The Forge MTG package to install.";
    };
  };

  config = lib.mkMerge [
    # Steam
    (lib.mkIf cfg.steam.enable {
      programs.steam.enable = true;
      environment.systemPackages = with pkgs; [steam-run];
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "steam"
          "steam-original"
          "steam-run"
        ];
    })

    # Lutris
    (lib.mkIf cfg.lutris.enable {
      environment.systemPackages = with pkgs; [
        lutris
        protonplus
      ];
    })

    # XIVLauncher
    (lib.mkIf cfg.xivlauncher.enable {
      environment.systemPackages = with pkgs; [
        xivlauncher
      ];
    })

    # Godot
    (lib.mkIf cfg.godot.enable {
      environment.systemPackages = with pkgs; [
        godot
      ];
    })

    # Sunshine
    (lib.mkIf cfg.sunshine.enable {
      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = true;
      };
      services.udev.extraRules = ''
        KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
      '';
    })

    # Nexon Launcher
    (lib.mkIf cfg.nexon-launcher.enable {
      hardware.steam-hardware.enable = lib.mkDefault true;
      hardware.uinput.enable = lib.mkDefault true;
      boot.kernelModules = ["uinput"];
      environment.systemPackages = [pkgs.nexon-launcher];
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) ["nexon-launcher"];
    })

    # Battle.net
    (lib.mkIf bnetCfg.enable {
      assertions = [
        {
          assertion = specialArgs.nix-battle-net.packages ? ${system}.battle-net;
          message = "nix-battle-net does not support system ${system}.";
        }
      ];

      hardware.steam-hardware.enable = lib.mkIf bnetCfg.enableControllerSupport (lib.mkDefault true);
      hardware.uinput.enable = lib.mkIf bnetCfg.enableControllerSupport (lib.mkDefault true);
      boot.kernelModules = lib.mkIf bnetCfg.enableControllerSupport ["uinput"];
      hardware.xpadneo.enable = lib.mkIf bnetCfg.enableXboxWireless (lib.mkDefault true);

      nixpkgs.overlays = [
        (_final: _prev: {
          battle-net = bnetCfg.package;
        })
      ];

      environment.systemPackages = [
        bnetCfg.package
      ];

      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "battle-net"
        ];
    })

    # Forge MTG
    (lib.mkIf forgeCfg.enable {
      environment.systemPackages = [
        forgeCfg.package
      ];
    })
  ];
}
