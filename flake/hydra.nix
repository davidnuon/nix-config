{
  nixpkgs,
  hostConfigurations,
  isoConfigurations,
}: {
  hosts = nixpkgs.lib.mapAttrs (_: cfg:
    {
      toplevel = cfg.config.system.build.toplevel;
    }
    // (nixpkgs.lib.optionalAttrs (cfg.config.system.build ? diskoScript) {
      disko = cfg.config.system.build.diskoScript;
    }))
  hostConfigurations;

  isos =
    nixpkgs.lib.mapAttrs (_: cfg: (
      {
        iso = cfg.config.system.build.isoImage;
      }
      // (nixpkgs.lib.optionalAttrs (cfg.config.system.build ? installerVhd) {
        vhd = cfg.config.system.build.installerVhd;
      })
    ))
    isoConfigurations;
}
