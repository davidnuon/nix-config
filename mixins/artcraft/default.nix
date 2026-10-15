{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: {
  imports = [
    specialArgs.artcraft-nix.nixosModules.default
  ];

  nixpkgs.overlays = [
    specialArgs.artcraft-nix.overlays.default
  ];

  programs.artcraft = {
    enable = true;
  };
}
