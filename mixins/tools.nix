{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.mixins.tools;
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
        pkgs.antigravity
        pkgs.antigravity-ide
        pkgs.antigravity-cli
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
