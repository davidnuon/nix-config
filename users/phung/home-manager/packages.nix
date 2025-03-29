{
  pkgs,
  config,
  ...
}: {
  home-manager.users.phung.home.packages = with pkgs; [
	google-chrome-stable
  ];
}
