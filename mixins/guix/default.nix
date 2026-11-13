{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.guix = {
    enable = lib.mkEnableOption "GNU Guix package manager daemon";
  };

  config = lib.mkIf config.mixins.guix.enable {
    services.guix.enable = true;
  };
}
