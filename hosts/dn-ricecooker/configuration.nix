{
  lib,
  config,
  pkgs,
  ...
}: {
  mixins = {
    base.enable = true;
    nixcache.client.enable = true;
    server.enable = true;
    docker.enable = true;
    agy.enable = true;
    virtualization.enable = true;
    tailscale.enable = true;
    flatpak.enable = true;
    garage.enable = true;
  };
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

  # Disable Wi-Fi interface (wlp2s0 - Realtek RTL8852BE PCIe)
  boot.blacklistedKernelModules = ["rtw89_8852be"];

  system.stateVersion = "25.11";
}
