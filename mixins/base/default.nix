{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.base = {
    enable = lib.mkEnableOption "base system configuration";
  };

  imports = [
    ./core.nix
    ./packages.nix
    ./desktop-core.nix
    ./desktop-gnome.nix
    ./desktop-lang-jp.nix
    ./unstable.nix
  ];
}
