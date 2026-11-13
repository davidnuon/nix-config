{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.patchy = {
    enable = lib.mkEnableOption "Patchy image editor";
  };

  config = lib.mkIf config.mixins.patchy.enable {
    environment.systemPackages = [
      pkgs.patchy
    ];
  };
}
