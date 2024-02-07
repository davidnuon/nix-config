{
  description = "davidnuon's NixOS configuration";
  inputs = {
    home-manager-2211.url = "https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz";
    nixpkgs-2211.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixos-hardware.url = "https://github.com/NixOS/nixos-hardware/archive/83e571b.tar.gz";

    home-manager-2311.url = "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
    #home-manager-2311.url = "github:nix-community/home-manager/23.11.tar.gz";
    nixpkgs-2311.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: {
    nixosConfigurations = {
      dn-jetbook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hosts/dn-jetbook
        ];
      };

      dn-ravenbook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/dn-ravenbook
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
