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

    "${nixos-hardware}/framework/13-inch/12th-gen-intel"

    ./k3s.nix
  ];
}
