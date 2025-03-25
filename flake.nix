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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: {
    devShells."x86_64-linux".default = let
      pkgs = import inputs.nixpkgs-2311 {
        system = "x86_64-linux";
      };
    in
      pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          nix
          vim
          home-manager
          git
          gnumake
          alejandra
        ];
      };

    devShells."aarch64-linux".default = let
      pkgs = import inputs.nixpkgs-2411 {
        system = "aarch64-linux";
      };
    in
      pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          nix
          vim
          home-manager
          git
          gnumake
          alejandra
        ];
      };

    nixosConfigurations = let
      inherit
        (builtins)
        listToAttrs
        map
        readDir
        attrNames
        ;
    in
      listToAttrs (map (name: {
        inherit name;
        value = import ./hosts/${name}/default.nix {
          specialArgs = inputs;
        };
      }) (attrNames (readDir ./hosts)));
  };
}
