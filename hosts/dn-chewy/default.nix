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
    ./chuwi.nix

    disko.nixosModules.disko
    ./disk-config.nix
  ];
}
