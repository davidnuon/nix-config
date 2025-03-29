{
  pkgs,
  config,
  ...
}: {
  home-manager.users.davidnuon.home.packages = with pkgs; [
  ];
}
