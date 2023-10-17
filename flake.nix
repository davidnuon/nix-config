{
  description = "davidnuon's NixOS configuration";

  inputs = {
  };

  outputs = {
    self,
    nixpkgs,
  } @ inputs: {
    nixosConfigurations = {
      dn-ravenbook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/dn-ravenbook.nix
        ];
      };
      specialArgs = {inherit inputs;};
    };
  };
}
