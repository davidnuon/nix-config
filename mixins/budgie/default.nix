{
  config,
  pkgs,
  lib,
  ...
}: {
  services.xserver.desktopManager.lumina.enable = true;
}
