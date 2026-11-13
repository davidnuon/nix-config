{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  cfg = config.mixins.creative;
  system = pkgs.stdenv.hostPlatform.system;

  # --- Affinity setup ---
  affinity-nix = specialArgs.affinity-nix or null;

  # --- ArtCraft setup ---
  artcraftCfg = config.programs.artcraft;
  rawArtcraft =
    if specialArgs ? artcraft-nix
    then import (specialArgs.artcraft-nix + "/default.nix") {inherit pkgs;}
    else {};
  data =
    if specialArgs ? artcraft-nix
    then lib.importJSON (specialArgs.artcraft-nix + "/versions.json")
    else {apps = {};};
  artcraftAppList = lib.attrNames data.apps;

  patchPkg = pkg:
    pkg.overrideAttrs (old: {
      runtimeDependencies = map lib.getLib ((old.runtimeDependencies or []) ++ [pkgs.libva]);
      appendRunpaths = (old.appendRunpaths or []) ++ ["/run/opengl-driver/lib"];
    });

  artcraftPackages =
    lib.mapAttrs (
      name: pkg:
        if name == "default"
        then
          pkgs.symlinkJoin {
            name = "artcraft";
            paths = map (app: artcraftPackages.${app}) (lib.filter (app: rawArtcraft ? ${app}) artcraftAppList);
          }
        else patchPkg pkg
    )
    rawArtcraft;

  # --- PhotoGIMP setup ---
  photogimpCfg = config.programs.photogimp;
in {
  options.mixins.creative = {
    affinity = {
      enable = lib.mkEnableOption "Affinity suite";
    };
    artcraft = {
      enable = lib.mkEnableOption "ArtCraft apps";
    };
    officecraft = {
      enable = lib.mkEnableOption "OfficeCraft apps";
    };
    patchy = {
      enable = lib.mkEnableOption "Patchy image editor";
    };
    photogimp = {
      enable = lib.mkEnableOption "PhotoGIMP";
    };
    libreoffice = {
      enable = lib.mkEnableOption "LibreOffice";
    };
  };

  # Preserve programs.artcraft for custom options
  options.programs.artcraft = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.artcraft.enable;
      description = "Whether to enable ArtCraft apps.";
    };

    apps = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames artcraftPackages));
      default = artcraftAppList;
      example = ["photocraft" "vectorcraft_0_4_0"];
      description = "Apps to install: `<app>` for its newest release, `<app>_<x>_<y>_<z>` to pin a version.";
    };

    linkFonts = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Link /usr/share/fonts to the system fonts so the apps' text tools find them.";
    };
  };

  # Preserve programs.photogimp for custom options
  options.programs.photogimp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.photogimp.enable;
      description = "Whether to enable PhotoGIMP.";
    };

    withPlugins = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to install PhotoGIMP with plugins enabled.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default =
        if photogimpCfg.withPlugins
        then specialArgs.nix-photo-gimp.packages.${system}.photo-gimp-with-plugins
        else specialArgs.nix-photo-gimp.packages.${system}.default;
      description = "PhotoGIMP package to install.";
    };
  };

  config = lib.mkMerge [
    # Affinity
    (lib.mkIf cfg.affinity.enable {
      nixpkgs.overlays = [
        affinity-nix.overlays.default
        (final: prev: {
          msitools = prev.msitools.overrideAttrs (_: {
            doCheck = false;
          });
        })
      ];
      environment.systemPackages = [pkgs.affinity-v3];
    })

    # ArtCraft
    (lib.mkIf artcraftCfg.enable {
      nixpkgs.overlays = [
        (_final: _prev: {
          artcraft = artcraftPackages;
          inherit (artcraftPackages) photocraft pixelcraft vectorcraft filmcraft fontcraft rawcraft;
        })
      ];
      environment.systemPackages = map (app: artcraftPackages.${app}) artcraftCfg.apps;
    })

    # OfficeCraft
    (lib.mkIf cfg.officecraft.enable {
      environment.systemPackages = [
        pkgs.officecraft.wordcraft
        pkgs.officecraft.figcraft
        pkgs.officecraft.deckcraft
        pkgs.officecraft.gridcraft
      ];
    })

    # Shared font directory linking for ArtCraft / OfficeCraft
    (lib.mkIf (artcraftCfg.enable || cfg.officecraft.enable) {
      fonts.fontDir.enable = true;
      systemd.tmpfiles.rules = [
        "d /usr/share 0755 root root -"
        "L+ /usr/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
      ];
    })

    # Patchy
    (lib.mkIf cfg.patchy.enable {
      environment.systemPackages = [
        pkgs.patchy
      ];
    })

    # PhotoGIMP
    (lib.mkIf photogimpCfg.enable {
      nixpkgs.overlays = [
        (_final: _prev: {
          photogimp = photogimpCfg.package;
        })
      ];
      environment.systemPackages = [
        photogimpCfg.package
      ];
    })

    # LibreOffice
    (lib.mkIf cfg.libreoffice.enable {
      environment.systemPackages = with pkgs; [
        libreoffice
      ];
    })
  ];
}
