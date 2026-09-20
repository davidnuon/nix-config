{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    (import "${specialArgs.home-manager}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})
    ./x13s-nixos/module.nix

    ../../mixins

    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
