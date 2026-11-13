{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./ollama.nix

    (import "${specialArgs.home-manager}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})

    specialArgs.disko.nixosModules.disko
    ./disk-config.nix

    ../../mixins

    # Below two modules stolen from @jmbaur
    # https://github.com/jmbaur/homelab/tree/main/nixos-modules/hardware/
    ./blackrock
    ./qualcomm
  ];
}
