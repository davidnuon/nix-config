{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.remote-desktop = {
    enable = lib.mkEnableOption "Remote Desktop (Remmina)";
  };

  config = lib.mkIf config.mixins.remote-desktop.enable {
    environment.systemPackages = with pkgs; [
      remmina
    ];
  };
}
