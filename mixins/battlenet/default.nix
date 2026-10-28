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

    package = lib.mkOption {
      type = lib.types.package;
      default = let
        bnet = specialArgs.nix-battle-net.packages.${system}.battle-net or pkgs.emptyDirectory;
      in
        if bnet ? override
        then
          bnet.override (lib.filterAttrs (_: v: v != null) {
            protonVersion = cfg.protonPackage;
            umu-launcher = cfg.umuPackage;
            environment = cfg.environment;
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
