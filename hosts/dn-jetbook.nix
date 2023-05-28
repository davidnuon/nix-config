{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./base
    ./home
  ];

  networking.hostName = "dn-jetbook";
}
