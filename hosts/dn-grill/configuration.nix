{
  lib,
  config,
  pkgs,
  ...
}: {
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dn-grill";

  services.openssh.enable = true;

  # Zeroconf DNS
  services.avahi.enable = true;

  # enp0s13f0u2 is the Framework Ethernet Module
  /*
  networking.interfaces.enp0s13f0u2.useDHCP = false;
  networking.interfaces.br0.useDHCP = true;

  # Bridge network so VMs can be exposed to the network
  networking.bridges = {
    "br0" = {
      interfaces = ["enp0s13f0u2"];
    };
  };
  */
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  # This isn't going anywhere
  time.timeZone = "America/Los_Angeles";

  # Disable laptop sleepy behavior
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  system.stateVersion = "23.11";
}
