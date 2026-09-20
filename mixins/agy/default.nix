{
  lib,
  config,
  pkgs,
  specialArgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.mixins.agy = {
    enable = lib.mkEnableOption "Google Antigravity";
  };

  config = lib.mkIf config.mixins.agy.enable {
    environment.systemPackages = [
      specialArgs.antigravity-nix.packages.${system}.default # Base App
      specialArgs.antigravity-nix.packages.${system}.google-antigravity-ide # IDE
      specialArgs.antigravity-nix.packages.${system}.google-antigravity-cli # CLI
    ];
  };
}
