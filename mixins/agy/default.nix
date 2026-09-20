{
  system,
  lib,
  config,
  pkgs,
  antigravity-nix,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
in {
  environment.systemPackages = [
    antigravity-nix.packages.${system}.default # Base App
    antigravity-nix.packages.${system}.google-antigravity-ide # IDE
    antigravity-nix.packages.${system}.google-antigravity-cli # CLI
  ];
}
