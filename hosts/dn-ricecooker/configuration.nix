{
  lib,
  config,
  pkgs,
  ...
}: {
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-ricecooker";

  services.openssh.enable = true;

  # Zeroconf DNS
  services.avahi.enable = true;

  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  # This isn't going anywhere
  time.timeZone = "America/Los_Angeles";

  # Disable laptop sleepy behavior
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  system.stateVersion = "25.11";
}
