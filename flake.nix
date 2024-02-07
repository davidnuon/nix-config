{
  description = "davidnuon's NixOS configuration";
  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware/83e571b";

    nixpkgs-2211.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager-2211.url = "github:nix-community/home-manager/release-22.11";
    home-manager-2211.inputs.nixpkgs.follows = "nixpkgs-2211";

    nixpkgs-2311.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager-2311.url = "github:nix-community/home-manager/release-23.11";
    home-manager-2311.inputs.nixpkgs.follows = "nixpkgs-2311";

    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
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
        NIX_CONFIG = "extra-experimental-features = nix-command";
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
      dn-jetbook = inputs.nixpkgs-2211.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hosts/dn-jetbook

          (import "${inputs.home-manager-2211}/nixos")
          (import ./mixins/home/davidnuon.nix {stateVersion = "22.11";})

          ./mixins/base
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
          (import ./mixins/home/davidnuon.nix {stateVersion = "23.11";})

          ./mixins/base
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
          (import ./mixins/home/davidnuon.nix {stateVersion = "23.11";})

          ./mixins/base
          ./mixins/flatpak
        ];
      };

      dn-silverbook = inputs.nixpkgs-2311.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hosts/dn-silverbook

          (import "${inputs.home-manager-2311}/nixos")
          (import ./mixins/home/davidnuon.nix {stateVersion = "23.11";})

          "${inputs.nixos-hardware}/framework/13-inch/7040-amd"

          ./mixins/base
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
          (import ./mixins/home/davidnuon.nix {stateVersion = "23.11";})

          "${inputs.nixos-hardware}/framework/13-inch/12th-gen-intel"

          ./mixins/base-2311
          ./mixins/virtualization
          ./mixins/tailscale
          ./mixins/flatpak
        ];
      };
    };
  };
}
