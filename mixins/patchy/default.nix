{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.patchy;
  patchyPackage = pkgs.callPackage ./package.nix {};
in {
  options.programs.patchy = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Patchy image editor.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = patchyPackage;
      description = "Patchy package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (_final: _prev: {
        patchy = cfg.package;
      })
    ];

    environment.systemPackages = [
      cfg.package
    ];
  };
}
