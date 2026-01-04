{
  description = "davidnuon's NixOS configuration";
  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-x13s.url = "github:davidnuon/x13s-nixos/x13s-changes";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
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
      value = import ./hosts/${name}/default.nix {
        specialArgs = inputs // {
          cleanVersion = builtins.head (builtins.match "([0-9]+\\.[0-9]+).*" nixpkgs.lib.version);
        };
      };
    }) (attrNames (readDir ./hosts)));
  };
}
