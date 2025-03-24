{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
  ];

  services.avahi.enable = true;
}
