{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.libreoffice = {
    enable = lib.mkEnableOption "LibreOffice";
  };

  config = lib.mkIf config.mixins.libreoffice.enable {
    environment.systemPackages = with pkgs; [
      libreoffice
    ];
  };
}
