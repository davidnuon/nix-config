{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    "${specialArgs.nixos-hardware}/framework/13-inch/12th-gen-intel"

    ./k3s.nix
  ];
}
