{
  lib,
  pkgs,
  config,
  specialArgs,
  ...
}: {
  imports = [
  ];
  programs = {
    hyprland = {
      enable = true;
    };
    waybar = {
      enable = true;
      package = pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      });
    };
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    kitty
    mako
    specialArgs.ags

    polkit_gnome
    libva-utils
    fuseiso
    udiskie
    gnome.adwaita-icon-theme
    gnome.gnome-themes-extra
    gsettings-desktop-schemas
    swaynotificationcenter
    wlr-randr
    ydotool
    wl-clipboard
    hyprland-protocols
    hyprpicker
    # swayidle
    # swaylock
    xdg-desktop-portal-hyprland
    hyprpaper
    wofi
    firefox-wayland
    swww
    grim
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    qt5.qtwayland
    qt6.qmake
    qt6.qtwayland
    adwaita-qt
    adwaita-qt6

    pavucontrol
  ];
}
