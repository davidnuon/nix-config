{
  nixpkgs,
  nixos-hardware,
  disko,
  ...
}:
nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  modules = [
    nixos-hardware.nixosModules.lenovo-thinkpad-x13s
    # ./wwan.nix

    disko.nixosModules.disko
    ./disk-config.nix

    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
