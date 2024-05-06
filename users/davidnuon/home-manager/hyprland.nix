{pkgs, ...}: {
  home-manager.users.davidnuon.home.packages = with pkgs; [
    gtksourceview
     webkitgtk
     accountsservice
  ];
}
