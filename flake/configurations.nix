{
  inputs,
  nixpkgs,
  stateVersion,
  extendedSpecialArgs ?
    inputs
    // {
      inherit inputs stateVersion;
      hosts = import ../hosts.nix;
      builders = import ../builders.nix;
    },
  ...
}: let
  mkConfigurationsFrom = dir: let
    inherit (nixpkgs) lib;
    entries = lib.filterAttrs (name: type: type == "directory" && name != "vm") (builtins.readDir dir);
  in
    lib.genAttrs (builtins.attrNames entries) (name:
      import (dir + "/${name}") inputs);
  sharedHostModules = [
    inputs.home-manager.nixosModules.home-manager
    ../users/davidnuon
    ../mixins
  ];
  hostConfigurations = nixpkgs.lib.mapAttrs (
    _: cfg:
      cfg.extendModules {
        specialArgs = extendedSpecialArgs;
        modules = sharedHostModules;
      }
  ) (mkConfigurationsFrom ../hosts);
  isoConfigurations = mkConfigurationsFrom ../isos;

  x86HostConfigurations =
    nixpkgs.lib.filterAttrs (
      name: cfg:
        (cfg.config.nixpkgs.system or "") == "x86_64-linux"
    )
    hostConfigurations;

  aarch64HostConfigurations =
    nixpkgs.lib.filterAttrs (
      name: cfg:
        (cfg.config.nixpkgs.system or "") == "aarch64-linux"
    )
    hostConfigurations;
in {
  inherit hostConfigurations isoConfigurations x86HostConfigurations aarch64HostConfigurations;
}
