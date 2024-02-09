{
  pkgs,
  config,
  ...
}: {
  home-manager.users.davidnuon.programs.git = {
    enable = true;
    userName = "David Nuon";
    userEmail = "davidnuongm@gmail.com";
    extraConfig.core.editor = "vim";
    extraConfig.init.defaultBranch = "main";
    lfs.enable = true;
  };
}
