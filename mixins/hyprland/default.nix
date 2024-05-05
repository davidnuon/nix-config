{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
	kitty
  ];
}
