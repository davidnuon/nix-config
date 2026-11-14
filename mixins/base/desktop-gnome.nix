{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.mixins.base.enable {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    programs.gnome-terminal.enable = true;

    services.gvfs.enable = true;
  };
}
