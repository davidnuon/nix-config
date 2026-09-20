{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.input-remapper = {
    enable = lib.mkEnableOption "Input Remapper";
  };

  config = lib.mkIf config.mixins.input-remapper.enable {
    services.input-remapper.enable = true;
  };
}
