{
  description = "Various NixOS VMs";
  inputs = {};

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
    };
  };
}
