{
  nixpkgs,
  sops-nix,
  ...
}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./nvidia.nix
    ./ollama.nix
    ./secrets.nix

    sops-nix.nixosModules.sops
  ];
}
