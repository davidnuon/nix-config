{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.distrobox = {
    enable = lib.mkEnableOption "Distrobox";
  };

  config = lib.mkIf config.mixins.distrobox.enable {
    environment.systemPackages = [pkgs.distrobox];
  };
}
