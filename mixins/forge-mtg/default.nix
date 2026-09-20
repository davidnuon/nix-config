{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  unstable-pkgs = import specialArgs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in {
  options.mixins.forge-mtg = {
    enable = lib.mkEnableOption "Forge MTG";
  };

  config = lib.mkIf config.mixins.forge-mtg.enable {
    environment.systemPackages = with unstable-pkgs; [
      forge-mtg
    ];
  };
}
