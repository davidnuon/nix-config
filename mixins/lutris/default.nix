{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.lutris = {
    enable = lib.mkEnableOption "Lutris";
  };

  config = lib.mkIf config.mixins.lutris.enable {
    environment.systemPackages = with pkgs; [
      lutris
      protonplus
    ];
  };
}
