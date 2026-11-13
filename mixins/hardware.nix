{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.mixins.hardware;
in {
  options.mixins.hardware = {
    ts100-driver = {
      enable = lib.mkEnableOption "TS100 printer driver";
    };
  };

  config = lib.mkMerge [
    # TS100 receipt printer driver
    (lib.mkIf cfg.ts100-driver.enable {
      services.printing = {
        enable = true;
        drivers = [pkgs.ts100-driver];
      };
    })
  ];
}
