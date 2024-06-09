{
  config,
  pkgs,
  lib,
  options,
  ...
}:
{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;

  services.xserver.desktopManager.gnome.enable = true;

  programs.gnome-terminal.enable = true;

  # TODO: Remove after all machines upgraded to 24.05
  services.xserver.displayManager.defaultSession = "gnome";
}
# Hack to make this not break 23.11 installations
// {
  # TODO: Add to upper attrset after 24.05 upgrade - services.displayManager.defaultSession = "gnome";
  services = lib.optionalAttrs (config.system.stateVersion == "24.05") {
    displayManager.defaultSession = "gnome";
  };
}
