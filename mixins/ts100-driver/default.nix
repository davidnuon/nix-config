{
  config,
  pkgs,
  ...
}: let
  ts100-driver = pkgs.callPackage ./driver.nix {};
in {
  imports = [];

  services.printing = {
    enable = true;
    drivers = [ts100-driver];
  };
}
