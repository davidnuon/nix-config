{
  pkgs,
  config,
  ...
}: {
  home-manager.users.davidnuon.programs.git = {
    enable = true;
    settings.user.name = "David Nuon";
    settings.user.email = "davidnuongm@gmail.com";
    settings.core.editor = "vim";
    settings.init.defaultBranch = "main";
    lfs.enable = true;
  };
}
