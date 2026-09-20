{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.godot = {
    enable = lib.mkEnableOption "Godot Engine";
  };

  config = lib.mkIf config.mixins.godot.enable {
    environment.systemPackages = with pkgs; [
      godot
    ];
  };
}
