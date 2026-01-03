{
  config,
  pkgs,
  lib,
  ...
}: {
  services.xserver.displayManager.sddm.enable = lib.mkIf (!config.services.displayManager.gdm.enable) true;

  services.desktopManager.plasma6.enable = true;
  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
  programs.dconf.enable = true;
}
