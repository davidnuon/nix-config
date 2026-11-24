{
  self,
  nixpkgs,
  ...
}: let
  inherit (self.configurations) isoConfigurations;
in {
  hosts =
    nixpkgs.lib.mapAttrs (
      _: cfg: {
        toplevel = cfg.config.system.build.toplevel;
      }
    )
    self.nixosConfigurations;

  # isos =
  #   nixpkgs.lib.mapAttrs (_: cfg: (
  #     {
  #       iso = cfg.config.system.build.isoImage;
  #     }
  #     // (nixpkgs.lib.optionalAttrs (cfg.config.system.build ? installerVhd) {
  #       vhd = cfg.config.system.build.installerVhd;
  #     })
  #   ))
  #   isoConfigurations;
}
