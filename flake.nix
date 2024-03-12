{
  description = "davidnuon's NixOS configuration";
  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware/ad2fd7b978d5e462048729a6c635c45d3d33c9ba";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs";

    nixpkgs-2311.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager-2311.url = "github:nix-community/home-manager/release-23.11";
    home-manager-2311.inputs.nixpkgs.follows = "nixpkgs-2311";
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
  };
}
