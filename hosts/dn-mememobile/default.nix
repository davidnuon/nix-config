{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./nvidia.nix
    ./ollama.nix
    ./secrets.nix

    specialArgs.sops-nix.nixosModules.sops
  ];
}
