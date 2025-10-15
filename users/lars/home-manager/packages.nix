{
  pkgs,
  config,
  ...
}: {
  home-manager.users.lars.home.packages = with pkgs; [
	firefox
  ];
}
