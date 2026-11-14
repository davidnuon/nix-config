{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./amd.nix
    ./ollama.nix

    specialArgs.disko.nixosModules.disko
    ./disk-config.nix

    ./mounts.nix
  ];
}
