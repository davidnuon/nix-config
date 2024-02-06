{
  description = "davidnuon's NixOS configuration";
  inputs = {
  };

  outputs = inputs @ {
    self,
    nixpkgs,
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
    };
  };
}
