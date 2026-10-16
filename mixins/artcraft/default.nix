{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  cfg = config.programs.artcraft;
  rawArtcraft = import (specialArgs.artcraft-nix + "/default.nix") {inherit pkgs;};
  data = lib.importJSON (specialArgs.artcraft-nix + "/versions.json");
  apps = lib.attrNames data.apps;

  patchPkg = pkg:
    pkg.overrideAttrs (old: {
      # lib.getLib: some of these (dbus) keep their shared objects in a separate
      # `lib` output, and the default output on the RPATH holds no library at all.
      runtimeDependencies = map lib.getLib ((old.runtimeDependencies or []) ++ [pkgs.libva]);
      # NVIDIA's libcuda / libnvcuvid / libnvidia-encode (FilmCraft's NVDEC/NVENC)
      # ship with the driver, not nixpkgs; NixOS exposes them here.
      appendRunpaths = (old.appendRunpaths or []) ++ ["/run/opengl-driver/lib"];
    });

  artcraftPackages =
    lib.mapAttrs (
      name: pkg:
        if name == "default"
        then
          pkgs.symlinkJoin {
            name = "artcraft";
            paths = map (app: artcraftPackages.${app}) (lib.filter (app: rawArtcraft ? ${app}) apps);
          }
        else patchPkg pkg
    )
    rawArtcraft;
in {
  options.programs.artcraft = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable the ArtCraft apps.";
    };

    apps = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames artcraftPackages));
      default = apps;
      example = ["photocraft" "vectorcraft_0_4_0"];
      description = "Apps to install: `<app>` for its newest release, `<app>_<x>_<y>_<z>` to pin a version.";
    };

    linkFonts = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Link /usr/share/fonts to the system fonts so the apps' text tools find them.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      nixpkgs.overlays = [
        (_final: _prev: {
          artcraft = artcraftPackages;
        })
      ];

      environment.systemPackages = map (app: artcraftPackages.${app}) cfg.apps;
    }
    (lib.mkIf cfg.linkFonts {
      fonts.fontDir.enable = true;
      systemd.tmpfiles.rules = [
        "d /usr/share 0755 root root -"
        "L+ /usr/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
      ];
    })
  ]);
}
