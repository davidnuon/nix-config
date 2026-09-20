{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.flatpak = {
    enable = lib.mkEnableOption "Flatpak";
  };

  config = lib.mkIf config.mixins.flatpak.enable {
    xdg.portal.enable = true;
    services.flatpak.enable = true;

    systemd.services.flatpak-repo = {
      wantedBy = ["multi-user.target"];
      path = [pkgs.flatpak];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
