{
  nixpkgs,
  disko,
  ...
}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    disko.nixosModules.disko
    ./disk-config.nix

    ./nvidia.nix
    ./prime.nix
    ./proart.nix
  ];
}
