{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./base
  ];

  networking.hostName = "dn-jetbook";
}
