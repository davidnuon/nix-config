{
  pkgs,
  config,
  ...
}: {
  home-manager.users.lars.programs.gnome-terminal = {
    themeVariant = "dark";
    profile = {
      colors = {
        backgroundColor = "rgb(0, 43, 54)";
        foregroundColor = "rgb(131, 148, 150)";
        useThemeColors = false;
      };
      visibleName = "default";
    };
  };
}
