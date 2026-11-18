{
  nixpkgs,
  nixos-hardware,
  ...
}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    "${nixos-hardware}/framework/13-inch/7040-amd"
  ];
}
