{
  config,
  pkgs,
  lib,
  ...
} @ args: {
  options.mixins.base = {
    enable = lib.mkEnableOption "base configuration";
  };

  config = lib.mkIf config.mixins.base.enable (lib.mkMerge [
    (import ./core.nix args)
    (import ./packages.nix args)
    (import ./desktop-core.nix args)
    (import ./desktop-gnome.nix args)
    (import ./desktop-lang-jp.nix args)
    (import ./unstable.nix args)
  ]);
}
