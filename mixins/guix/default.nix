{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.guix = {
    enable = lib.mkEnableOption "Guix package manager";
  };

  config = lib.mkIf config.mixins.guix.enable {
    services.guix.enable = true;
  };
}
