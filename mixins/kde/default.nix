{
  config,
  pkgs,
  lib,
  ...
}: {
  services.xserver.displayManager.sddm.enable = lib.mkIf (!config.services.xserver.displayManager.gdm.enable) true;

  services.xserver.desktopManager.plasma5.enable = true;
  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
}
