{
  system,
  lib,
  config,
  pkgs,
  specialArgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
in {
  environment.systemPackages = [
    specialArgs.antigravity-nix.packages.${system}.default # Base App
    specialArgs.antigravity-nix.packages.${system}.google-antigravity-ide # IDE
    specialArgs.antigravity-nix.packages.${system}.google-antigravity-cli # CLI
  ];
}
