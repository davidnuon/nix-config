{
  config,
  pkgs,
  lib,
  options,
  ...
}: {
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.desktopManager.gnome.enable = true;
  programs.gnome-terminal.enable = true;
}
