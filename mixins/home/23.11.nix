# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{version}: {
  config,
  pkgs,
  ...
}: let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
    sha256 = "7f4124a73a29eef91e8ba0876bd44c0cf59a1abc4382c20491492743fe3b3675";
  };
in {
  imports = [
    (import "${home-manager}/nixos")
    (import ./davidnuon.nix {stateVersion = version;})
  ];

  home-manager.useGlobalPkgs = true;
}
