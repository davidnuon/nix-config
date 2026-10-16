{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  affinity-nix = specialArgs.affinity-nix;
in {
  nixpkgs.overlays = [
    affinity-nix.overlays.default
    (final: prev: {
      msitools = prev.msitools.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];
  environment.systemPackages = [pkgs.affinity-v3];
}
