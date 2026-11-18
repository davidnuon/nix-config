inputs @ {
  self,
  nixpkgs,
  affinity-nix,
  aerothemeplasma-nix,
  disko,
  antigravity-nix,
  artcraft-nix,
  nix-photo-gimp,
  nix-battle-net,
  graphite-editor,
  forge,
  ...
}: let
  inherit
    (builtins)
    listToAttrs
    map
    readDir
    attrNames
    ;
  systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
  flakeLib = import ./lib.nix {inherit nixpkgs inputs;};
  mkConfigurationsFrom = flakeLib.mkConfigurationsFrom;
  configuratons = import ./configurations.nix {
    inherit
      inputs
      nixpkgs
      mkConfigurationsFrom
      ;
    cleanVersion = flakeLib.extendedSpecialArgs.cleanVersion;
  };

  inherit (configuratons) hostConfigurations x86HostConfigurations aarch64HostConfigurations isoConfigurations;
in {
  hydraJobs = import ./hydra.nix {
    inherit nixpkgs hostConfigurations isoConfigurations;
  };

  devShells = import ./devShell.nix {inherit inputs systems;};

  packages = {
    x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      systemHosts = x86HostConfigurations;
      systemIsos = nixpkgs.lib.filterAttrs (_: cfg: (cfg.config.nixpkgs.system or "") == "x86_64-linux") isoConfigurations;
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
      // (nixpkgs.lib.mapAttrs (_: cfg: cfg.config.system.build.toplevel) systemHosts)
      // (nixpkgs.lib.mapAttrs (_: cfg: cfg.config.system.build.isoImage) systemIsos);

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
      // (nixpkgs.lib.mapAttrs (_: cfg: cfg.config.system.build.isoImage) systemIsos)
      // (nixpkgs.lib.concatMapAttrs (
          name: cfg:
            (nixpkgs.lib.optionalAttrs (cfg.config.system.build ? installerVhd) {
              "${name}-vhd" = cfg.config.system.build.installerVhd;
            })
            // (nixpkgs.lib.optionalAttrs (name == "dn-blackleg-iso" && cfg.config.system.build ? installerVhd) {
              "dn-blackleg-vhd" = cfg.config.system.build.installerVhd;
            })
            // (nixpkgs.lib.optionalAttrs (name == "dn-microwave-iso" && cfg.config.system.build ? installerVhd) {
              "dn-microwave-vhd" = cfg.config.system.build.installerVhd;
            })
            // (nixpkgs.lib.optionalAttrs (name == "dn-installer-iso" && cfg.config.system.build ? installerVhd) {
              "dn-installer-vhd" = cfg.config.system.build.installerVhd;
              "dn-installer" = cfg.config.system.build.installerVhd;
            })
        )
        systemIsos);
  };

  overlays.default = import ../pkgs flakeLib.extendedSpecialArgs;

  nixosConfigurations = hostConfigurations // isoConfigurations;
}
