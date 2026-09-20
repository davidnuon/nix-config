{
  config,
  pkgs,
  lib,
  ...
}: let
  ts100-driver = pkgs.callPackage ./driver.nix {};
in {
  options.mixins.ts100-driver = {
    enable = lib.mkEnableOption "TS100 printer driver";
  };

  config = lib.mkIf config.mixins.ts100-driver.enable {
    services.printing = {
      enable = true;
      drivers = [ts100-driver];
    };
  };
}
