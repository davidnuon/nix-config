{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.xosview = {
    enable = lib.mkEnableOption "xosview";
  };

  config = lib.mkIf config.mixins.xosview.enable {
    environment.systemPackages = with pkgs; [
      xosview
    ];
  };
}
