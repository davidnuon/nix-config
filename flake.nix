{
  description = "davidnuon's NixOS configuration";
  inputs = {
    home-manager-2211.url = "https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz";
    nixos-hardware.url = "https://github.com/NixOS/nixos-hardware/archive/83e571b.tar.gz";
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

      dn-silverbook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          "${inputs.nixos-hardware}/framework/13-inch/7040-amd"
          (import "${inputs.home-manager-2211}/nixos")
          (import ./mixins/home/davidnuon.nix {stateVersion = "22.11";})
          ./hosts/dn-silverbook
          ./mixins/base
          ./mixins/virtualization
          ./mixins/tailscale
          ./mixins/flatpak
          ./mixins/libreoffice
        ];
      };
    };
  };
}
