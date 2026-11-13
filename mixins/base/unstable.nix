{
  config,
  pkgs,
  specialArgs,
  lib,
  ...
}: let
  unstable-pkgs = import specialArgs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in {
  config = lib.mkIf config.mixins.base.enable {
    environment.systemPackages = with unstable-pkgs; [
      vscode
    ];
  };
}
