{
  description = "davidnuon's NixOS configuration";
  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-x13s.url = "github:davidnuon/x13s-nixos/x13s-changes";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs";

    nixpkgs-2311.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager-2311.url = "github:nix-community/home-manager/release-23.11";
    home-manager-2311.inputs.nixpkgs.follows = "nixpkgs-2311";

    nixpkgs-2405.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager-2405.url = "github:nix-community/home-manager/release-24.05";
    home-manager-2405.inputs.nixpkgs.follows = "nixpkgs-2405";

    nixpkgs-2411.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager-2411.url = "github:nix-community/home-manager/release-24.11";
    home-manager-2411.inputs.nixpkgs.follows = "nixpkgs-2411";

    nixpkgs-2505.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager-2505.url = "github:nix-community/home-manager/release-25.05";
    home-manager-2505.inputs.nixpkgs.follows = "nixpkgs-2505";

    nixpkgs-2511.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager-2511.url = "github:nix-community/home-manager/release-25.11";
    home-manager-2511.inputs.nixpkgs.follows = "nixpkgs-2511";
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
        specialArgs = inputs;
      };
    }) (attrNames (readDir ./hosts)));
  };
}
