# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ version } : {
  config,
  pkgs,
  ...
}: let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-${version}.tar.gz";
  };
in {
  imports = [
    (import "${home-manager}/nixos")
    (import ./davidnuon.nix {stateVersion = version;})
  ];

  home-manager.useGlobalPkgs = true;
}