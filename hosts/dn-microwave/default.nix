{specialArgs, ...}:
specialArgs.nixpkgs-2311.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    (import "${specialArgs.home-manager-2311}/nixos")
    (import ../../users/davidnuon {stateVersion = "24.11";})

    ./blackrock
    ../../mixins/base
  ];
}
