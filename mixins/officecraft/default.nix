{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.officecraft = {
    enable = lib.mkEnableOption "OfficeCraft apps";
  };

  config = lib.mkIf config.mixins.officecraft.enable {
    environment.systemPackages = [
      pkgs.officecraft.wordcraft
      pkgs.officecraft.figcraft
      pkgs.officecraft.deckcraft
      pkgs.officecraft.gridcraft
    ];

    fonts.fontDir.enable = true;
    systemd.tmpfiles.rules = [
      "d /usr/share 0755 root root -"
      "L+ /usr/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
    ];
  };
}
