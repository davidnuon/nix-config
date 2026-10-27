{
  config,
  pkgs,
  ...
}: {
  imports = [];

  xdg.portal.enable = true;
  services.flatpak.enable = true;

  # Ensure the centralized font directory is created at /run/current-system/sw/share/X11/fonts
  fonts.fontDir.enable = true;

  # Expose host fonts and configure global Flatpak overrides so all Flatpak apps can read system and user fonts
  systemd.tmpfiles.rules = [
    "d /usr/share 0755 root root -"
    "L+ /usr/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
    "d /var/lib/flatpak/overrides 0755 root root -"
    "L+ /var/lib/flatpak/overrides/global - - - - ${pkgs.writeText "flatpak-global-overrides" ''
      [Context]
      filesystems=/nix/store:ro;/run/current-system/sw/share/X11/fonts:ro;xdg-data/fonts:ro;~/.local/share/fonts:ro;~/.icons:ro;
    ''}"
  ];

  systemd.services.flatpak-repo = {
    wantedBy = ["multi-user.target"];
    path = [pkgs.flatpak];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
