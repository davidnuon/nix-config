{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    (import "${specialArgs.home-manager}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})
    specialArgs.nixos-hardware.nixosModules.lenovo-thinkpad-x13s
    # ./wwan.nix

    specialArgs.disko.nixosModules.disko
    ./disk-config.nix

    ../../mixins
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
