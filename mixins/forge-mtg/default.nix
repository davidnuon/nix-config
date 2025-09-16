{
  config,
  pkgs,
  specialArgs,
  ...
}: let
  unstable-pkgs = import specialArgs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in {
  environment.systemPackages = with unstable-pkgs; [
    forge-mtg
  ];
}
