{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}: let
  forge-src = specialArgs.forge or specialArgs.forge-src or null;

  unstable-pkgs = import specialArgs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };

  cfg = config.programs.forge-mtg;

  forge-git =
    if forge-src == null
    then throw "forge input is not provided in flake inputs"
    else
      (unstable-pkgs.forge-mtg.overrideMavenAttrs (old: {
        pname = "forge-mtg";
        version = "unstable-${forge-src.shortRev or "latest"}";
        src = forge-src;
        mvnHash = cfg.mvnHash;
        installPhase = builtins.replaceStrings ["-${old.version}-"] ["-*-"] old.installPhase;
      }));

  isUpToDate =
    cfg.useUpToDate
    || cfg.upToDate
    || (config.forge-mtg.useUpToDate or false)
    || (config.forge-mtg.upToDate or false);
in {
  options = {
    programs.forge-mtg = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to install Forge MTG.";
      };

      useUpToDate = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to use the up-to-date build for Forge pinned via flake input.";
      };

      upToDate = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Alias for programs.forge-mtg.useUpToDate.";
      };

      mvnHash = lib.mkOption {
        type = lib.types.str;
        default = "sha256-LkrZ1Ufem57dfYpBadQxsdb38kLedGYtJAceMi+jt2w=";
        description = "Maven dependencies output hash when building Forge from source.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default =
          if isUpToDate
          then forge-git
          else unstable-pkgs.forge-mtg;
        defaultText = lib.literalExpression "if config.programs.forge-mtg.useUpToDate then <forge-git> else unstable-pkgs.forge-mtg";
        description = "The Forge MTG package to install.";
      };
    };

    # Convenient alias options directly under forge-mtg
    forge-mtg = {
      useUpToDate = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Alias for programs.forge-mtg.useUpToDate.";
      };

      upToDate = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Alias for programs.forge-mtg.useUpToDate.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];
  };
}
