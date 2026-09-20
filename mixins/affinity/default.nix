{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  affinity-nix = specialArgs.affinity-nix;
in {
  options.mixins.affinity = {
    enable = lib.mkEnableOption "Affinity Suite";
  };

  config = lib.mkIf config.mixins.affinity.enable {
    nixpkgs.overlays = [affinity-nix.overlays.default];
    environment.systemPackages = [pkgs.affinity-v3];
  };
}
