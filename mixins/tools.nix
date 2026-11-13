{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  cfg = config.mixins.tools;
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.mixins.tools = {
    agy = {
      enable = lib.mkEnableOption "Google Antigravity";
    };

    guix = {
      enable = lib.mkEnableOption "GNU Guix package manager daemon";
    };

    xosview = {
      enable = lib.mkEnableOption "xosview system monitor";
    };
  };

  config = lib.mkMerge [
    # Google Antigravity
    (lib.mkIf cfg.agy.enable {
      environment.systemPackages = [
        specialArgs.antigravity-nix.packages.${system}.default # Base App
        specialArgs.antigravity-nix.packages.${system}.google-antigravity-ide # IDE
        specialArgs.antigravity-nix.packages.${system}.google-antigravity-cli # CLI
      ];
    })

    # GNU Guix
    (lib.mkIf cfg.guix.enable {
      services.guix.enable = true;
    })

    # xosview
    (lib.mkIf cfg.xosview.enable {
      environment.systemPackages = with pkgs; [
        xosview
      ];
    })
  ];
}
