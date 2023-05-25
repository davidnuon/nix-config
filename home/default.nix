{pkgs, ...}:
with pkgs; {
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
  };

  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "palenight";
      package = pkgs.palenight-theme;
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

  home.sessionVariables.GTK_THEME = "palenight";

  home.stateVersion = "22.11";
}
