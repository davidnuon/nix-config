{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    (import "${specialArgs.home-manager}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})

    specialArgs.disko.nixosModules.disko
    ./disk-config.nix

    ../../mixins/nixcache/client.nix
    ../../mixins/base
    ../../mixins/kde
    ../../mixins/docker
    ../../mixins/tailscale
    ../../mixins/flatpak
  ];
}
