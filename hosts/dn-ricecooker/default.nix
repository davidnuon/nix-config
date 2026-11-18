{nixpkgs, ...}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    ./jenkins.nix
    ./k3s.nix
  ];
}
