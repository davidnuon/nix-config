{
  config,
  pkgs,
  lib,
  options,
  ...
}: {
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  programs.gnome-terminal.enable = true;
}
