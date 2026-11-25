{
  config,
  lib,
  pkgs,
  plasma-manager,
  ...
}: let
  kdeCfg = config.mixins.desktop.kde;
  panelProfiles = {
    desktop-widescreen = import ./panels/desktop-widescreen.nix {inherit config lib pkgs;};
  };
in {
  home-manager.users.davidnuon = lib.mkIf kdeCfg.enable {
    home.packages = [
      plasma-manager.packages.${pkgs.stdenv.hostPlatform.system}.rc2nix
    ];

    programs.plasma = {
      enable = true;
      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        theme = "default";
        colorScheme = "BreezeDark";
        iconTheme = "breeze-dark";
        cursor.theme = "breeze_cursors";
      };
      panels = lib.mkIf (kdeCfg.panelProfile != null) panelProfiles.${kdeCfg.panelProfile};
    };
  };
}
