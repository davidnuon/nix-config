{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.xivlauncher = {
    enable = lib.mkEnableOption "XIVLauncher";
  };

  config = lib.mkIf config.mixins.xivlauncher.enable {
    environment.systemPackages = with pkgs; [
      xivlauncher
    ];
  };
}
