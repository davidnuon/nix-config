{
  description = "davidnuon's NixOS configuration";
  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    aerothemeplasma-nix = {
      url = "github:nyakase/aerothemeplasma-nix/26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    affinity-nix.url = "github:davidnuon/affinity-nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    affinity-nix,
    aerothemeplasma-nix,
    disko,
    antigravity-nix,
    ...
  }: let
    inherit
      (builtins)
      listToAttrs
      map
      readDir
      attrNames
      filter
      pathExists
      ;

    cleanVersion = builtins.head (builtins.match "([0-9]+\\.[0-9]+).*" nixpkgs.lib.version);
    extendedSpecialArgs =
      inputs
      // {
        inherit cleanVersion;
      };

    # Filter out directories in ./hosts that are not NixOS host definitions
    isHost = name: pathExists (./hosts + "/${name}/configuration.nix");
    hostNames = filter isHost (attrNames (readDir ./hosts));

    # Base host configurations
    baseConfigurations = listToAttrs (map (name: {
        inherit name;
        value = import ./hosts/${name}/default.nix {
          specialArgs = extendedSpecialArgs;
        };
      })
      hostNames);

    # Installer ISO configurations for each host
    isoConfigurations = listToAttrs (map (name: {
        name = "${name}-iso";
        value = baseConfigurations.${name}.extendModules {
          modules = [./mixins/installer];
        };
      })
      hostNames);

    # Group ISO packages by host system architecture
    supportedSystems = ["x86_64-linux" "aarch64-linux"];
    packagesBySystem = listToAttrs (map (system: {
        name = system;
        value = listToAttrs (
          nixpkgs.lib.concatLists (map (name: let
            isoConfig = isoConfigurations."${name}-iso";
            hostSystem = baseConfigurations.${name}.config.nixpkgs.hostPlatform.system;
          in
            if hostSystem == system
            then [
              {
                name = "${name}-iso";
                value = isoConfig.config.system.build.isoImage;
              }
              {
                name = "${name}-installer";
                value = isoConfig.config.system.build.isoImage;
              }
            ]
            else [])
          hostNames)
        );
      })
      supportedSystems);
  in {
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

    packages = packagesBySystem;

    nixosConfigurations = baseConfigurations // isoConfigurations;
  };
}
