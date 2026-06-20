{
  description = "davidnuon's NixOS configuration";
  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-x13s.url = "github:davidnuon/x13s-nixos/x13s-changes";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    affinity-nix.url = "github:davidnuon/affinity-nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    affinity-nix,
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
        specialArgs =
          inputs
          // {
            cleanVersion = builtins.head (builtins.match "([0-9]+\\.[0-9]+).*" nixpkgs.lib.version);
          };
      };
<<<<<<< HEAD
    }) (attrNames (readDir ./hosts)));
=======

    nixosConfigurations = {
      dn-jetbook = inputs.nixpkgs-2311.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hosts/dn-jetbook

          (import "${inputs.home-manager-2311}/nixos")
          (import ./users/davidnuon {stateVersion = "23.11";})

          ./mixins/kde
          ./mixins/base
          ./mixins/docker
          ./mixins/tailscale
          ./mixins/flatpak
          ./mixins/virtualization
        ];
      };

      dn-ravenbook = inputs.nixpkgs-2311.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hosts/dn-ravenbook

          (import "${inputs.home-manager-2311}/nixos")
          (import ./users/davidnuon {stateVersion = "23.11";})

          ./mixins/base
          ./mixins/docker
          ./mixins/tailscale
          ./mixins/flatpak
          ./mixins/libreoffice
        ];
      };

      dn-thickbook = inputs.nixpkgs-2311.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hosts/dn-thickbook

          (import "${inputs.home-manager-2311}/nixos")
          (import ./users/davidnuon {stateVersion = "23.11";})

          ./mixins/base
          ./mixins/docker
          ./mixins/flatpak
        ];
      };

      dn-silverbook = inputs.nixpkgs-2311.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hosts/dn-silverbook

          (import "${inputs.home-manager-2311}/nixos")
          (import ./users/davidnuon {stateVersion = "23.11";})

          "${inputs.nixos-hardware}/framework/13-inch/7040-amd"

          ./mixins/kde
          ./mixins/steam
          ./mixins/base
          ./mixins/docker
          ./mixins/remote-desktop
          ./mixins/lutris
          ./mixins/virtualization
          ./mixins/tailscale
          ./mixins/flatpak
          ./mixins/libreoffice
        ];
      };

      dn-grill = inputs.nixpkgs-2311.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hosts/dn-grill

          (import "${inputs.home-manager-2311}/nixos")
          (import ./users/davidnuon {stateVersion = "23.11";})

          "${inputs.nixos-hardware}/framework/13-inch/12th-gen-intel"

          ./mixins/base
          ./mixins/docker
          ./mixins/virtualization
          ./mixins/tailscale
          ./mixins/flatpak
        ];
      };
    };
>>>>>>> 5b29d42b7e7b8ce96aefe17116c229a9992fa251
  };
}
