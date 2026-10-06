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
in {
  options = {
    programs.forge-mtg = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to install Forge MTG.";
      };

      useHead = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to use the HEAD build for Forge pinned via flake input.";
      };

      mvnHash = lib.mkOption {
        type = lib.types.str;
        default = "sha256-LkrZ1Ufem57dfYpBadQxsdb38kLedGYtJAceMi+jt2w=";
        description = "Maven dependencies output hash when building Forge from source.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default =
          if cfg.useHead
          then forge-git
          else unstable-pkgs.forge-mtg;
        defaultText = lib.literalExpression "if config.programs.forge-mtg.useHead then <forge-git> else unstable-pkgs.forge-mtg";
        description = "The Forge MTG package to install.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];
  };
}
