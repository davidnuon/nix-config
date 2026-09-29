{ config, pkgs, ... }:

{
  # 1. Disable all system sleep, suspend, and hibernate states
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # 3. Prevent GDM / GNOME from sleeping when no user is logged in
  # (Fixes the specific 'gdm-greeter' broadcast issue)
  systemd.services."gdm".wantedBy = [ "multi-user.target" ];
  
  # Tell GNOME's power management tool explicitly not to sleep
  services.gnome.gnome-keyring.enable = true; # ensures settings apply cleanly
}
