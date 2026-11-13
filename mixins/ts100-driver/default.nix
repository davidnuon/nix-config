{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.ts100-driver = {
    enable = lib.mkEnableOption "TS100 printer driver";
  };

  config = lib.mkIf config.mixins.ts100-driver.enable {
    services.printing = {
      enable = true;
      drivers = [pkgs.ts100-driver];
    };
  };
}
