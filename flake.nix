{
  description = "davidnuon's NixOS configuration";
  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-x13s.url = "github:davidnuon/x13s-nixos/x13s-changes";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
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
      ;
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

    nixosConfigurations = listToAttrs (map (name: {
      inherit name;
      value =
        import ./hosts/${name}/default.nix {
          specialArgs =
            inputs
            // {
              cleanVersion = builtins.head (builtins.match "([0-9]+\\.[0-9]+).*" nixpkgs.lib.version);
            };
        };
    }) (attrNames (readDir ./hosts)));
  };
}
