{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  affinity-nix = specialArgs.affinity-nix;
in {
  nixpkgs.overlays = [affinity-nix.overlays.default];
  environment.systemPackages = [ pkgs.affinity-v3 ];
}
