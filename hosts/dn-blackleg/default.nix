{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    specialArgs.nixos-hardware.nixosModules.lenovo-thinkpad-x13s
    # ./wwan.nix

    specialArgs.disko.nixosModules.disko
    ./disk-config.nix

    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
