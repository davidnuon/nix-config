{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  cfg = config.programs.photogimp;
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.programs.photogimp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
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
        if cfg.withPlugins
        then specialArgs.nix-photo-gimp.packages.${system}.photo-gimp-with-plugins
        else specialArgs.nix-photo-gimp.packages.${system}.default;
      description = "PhotoGIMP package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (_final: _prev: {
        photogimp = cfg.package;
      })
    ];

    environment.systemPackages = [
      cfg.package
    ];
  };
}
