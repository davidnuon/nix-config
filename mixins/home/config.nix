{pkgs, ...}:
with pkgs; {
  home-manager.users.davidnuon = {
    home.packages = [
      discord
      vscode
      firefox
    ];

    programs.git = {
      enable = true;
      userName = "David Nuon";
      userEmail = "davidnuongm@gmail.com";
      extraConfig.core.editor = "vim";
      extraConfig.init.defaultBranch = "main";
      lfs.enable = true;
    };

    gtk = {
      enable = true;

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      cursorTheme = {
        name = "Numix-Cursor";
        package = pkgs.numix-cursor-theme;
      };

      gtk3.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };

      gtk4.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
    };

    programs.gnome-terminal = {
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

    home.sessionVariables.GTK_THEME = "palenight";
    home.stateVersion = "22.11";
  };
}
