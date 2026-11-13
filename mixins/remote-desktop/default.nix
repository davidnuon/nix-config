{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.remote-desktop = {
    enable = lib.mkEnableOption "Remmina remote desktop";
  };

  config = lib.mkIf config.mixins.remote-desktop.enable {
    environment.systemPackages = with pkgs; [
      remmina
    ];
  };
}
