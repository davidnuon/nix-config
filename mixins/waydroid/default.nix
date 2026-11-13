{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.waydroid = {
    enable = lib.mkEnableOption "Waydroid";
  };

  config = lib.mkIf config.mixins.waydroid.enable {
    virtualisation.waydroid.enable = true;
  };
}
