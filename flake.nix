{
  description = "davidnuon's NixOS configuration";
  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    aerothemeplasma-nix = {
      url = "github:davidnuon/aerothemeplasma-nix/26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    affinity-nix.url = "github:davidnuon/affinity-nix";

    artcraft-nix = {
      url = "github:ipeglin/artcraft-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-photo-gimp = {
      url = "github:Libadoxon/nix-photo-gimp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-battle-net = {
      url = "github:gmaxpwnage/nix-battle-net";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    forge = {
      url = "github:Card-Forge/forge";
      flake = false;
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    buildbot-nix = {
      url = "github:nix-community/buildbot-nix";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    affinity-nix,
    aerothemeplasma-nix,
    disko,
    antigravity-nix,
    artcraft-nix,
    nix-photo-gimp,
    nix-battle-net,
    ...
  }: let
    inherit
      (builtins)
      listToAttrs
      map
      readDir
      attrNames
      ;
    extendedSpecialArgs =
      inputs
      // {
        cleanVersion = builtins.head (builtins.match "([0-9]+\\.[0-9]+).*" nixpkgs.lib.version);
        forge-src = inputs.forge;
        hosts = import ./hosts.nix;
      };

    mkConfigurationsFrom = dir: let
      entries = nixpkgs.lib.filterAttrs (name: type: type == "directory" && name != "vm") (readDir dir);
    in
      nixpkgs.lib.genAttrs (attrNames entries) (name:
        import (dir + "/${name}") {
          specialArgs = extendedSpecialArgs;
        });

    hostConfigurations = mkConfigurationsFrom ./hosts;
    isoConfigurations = mkConfigurationsFrom ./isos;

    x86HostConfigurations =
      nixpkgs.lib.filterAttrs (
        name: cfg:
          (cfg.config.nixpkgs.system or "") == "x86_64-linux"
      )
      hostConfigurations;

    hydraJobs = nixpkgs.lib.mapAttrs (_: cfg: cfg.config.system.build.toplevel) x86HostConfigurations;
  in {
    inherit hydraJobs;

    devShells = let
      systems = ["x86_64-linux" "aarch64-linux" "aaarch64-darwin"];
    in
      listToAttrs (map (system: {
          name = system;
          value =
            import ./devShell.nix
            {
              inherit system;
              specialArgs = inputs;
            };
        })
        systems);

    packages = {
      x86_64-linux = let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in
        {
          all-x86 = pkgs.linkFarm "all-x86-configurations" (
            nixpkgs.lib.mapAttrsToList (name: cfg: {
              inherit name;
              path = cfg.config.system.build.toplevel;
            })
            x86HostConfigurations
          );
        }
        // (nixpkgs.lib.mapAttrs (_: cfg: cfg.config.system.build.toplevel) x86HostConfigurations);

      aarch64-linux = {
        dn-blackleg-iso = self.nixosConfigurations.dn-blackleg-iso.config.system.build.isoImage;
        dn-microwave-iso = self.nixosConfigurations.dn-microwave-iso.config.system.build.isoImage;
        dn-blackleg-vhd = self.nixosConfigurations.dn-blackleg-iso.config.system.build.installerVhd;
        dn-microwave-vhd = self.nixosConfigurations.dn-microwave-iso.config.system.build.installerVhd;
        dn-installer-iso = self.nixosConfigurations.dn-installer-iso.config.system.build.isoImage;
        dn-installer-vhd = self.nixosConfigurations.dn-installer-iso.config.system.build.installerVhd;
        dn-installer = self.nixosConfigurations.dn-installer-iso.config.system.build.installerVhd;
      };
    };

    nixosConfigurations = hostConfigurations // isoConfigurations;
  };
}
