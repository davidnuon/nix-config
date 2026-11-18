{
  inputs,
  nixpkgs,
  mkConfigurationsFrom,
  stateVersion,
  ...
}: let
  sharedHostModules = [
    inputs.home-manager.nixosModules.home-manager
    ../users/davidnuon
    ../mixins
  ];
  hostConfigurations = nixpkgs.lib.mapAttrs (
    _: cfg:
      cfg.extendModules {
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
