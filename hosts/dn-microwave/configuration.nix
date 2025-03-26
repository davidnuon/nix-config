{
  lib,
  config,
  pkgs,
  ...
}: {
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-microwave";

  services.openssh.enable = true;
  hardware.blackrock.enable = true;

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

  system.stateVersion = "24.11";
}
