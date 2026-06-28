{
  config,
  pkgs,
  lib,
  options,
  ...
}: {
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.gnome-terminal.enable = true;

  services.gvfs.enable = true;
}
