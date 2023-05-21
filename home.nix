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
  home.stateVersion = "22.11";
}
