{
  self,
  nixpkgs,
  ...
}: let
  inherit (self.library) mkConfigurationsFrom;

  configurationsBySystem = system: configs:
    nixpkgs.lib.filterAttrs (
      name: cfg:
        (cfg.config.nixpkgs.system or "") == system
    )
    configs;

  x86HostConfigurations = configurationsBySystem "x86_64-linux" self.nixosConfigurations;
  aarch64HostConfigurations = configurationsBySystem "aarch64-linux" self.nixosConfigurations;
  isoConfigurations = mkConfigurationsFrom ../isos;
in {
  x86_64-linux = let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    systemHosts = x86HostConfigurations;
  in
    {
      all-x86 = pkgs.linkFarm "all-x86-configurations" (
        nixpkgs.lib.mapAttrsToList (name: cfg: {
          inherit name;
          path = cfg.config.system.build.toplevel;
        })
        systemHosts
      );
    }
    // (nixpkgs.lib.mapAttrs (_: cfg: cfg.config.system.build.toplevel) systemHosts);
  aarch64-linux = let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
    systemHosts = aarch64HostConfigurations;
    systemIsos = nixpkgs.lib.filterAttrs (_: cfg: (cfg.config.nixpkgs.system or "") == "aarch64-linux") isoConfigurations;
  in
    {
      all-aarch64 = pkgs.linkFarm "all-aarch64-configurations" (
        nixpkgs.lib.mapAttrsToList (name: cfg: {
          inherit name;
          path = cfg.config.system.build.toplevel;
        })
        systemHosts
      );
    }
    // (nixpkgs.lib.mapAttrs (_: cfg: cfg.config.system.build.toplevel) systemHosts)
    // (nixpkgs.lib.mapAttrs (_: cfg: cfg.config.system.build.isoImage) systemIsos);
}
