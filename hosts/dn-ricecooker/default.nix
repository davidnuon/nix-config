{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    (import "${specialArgs.home-manager}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})

    ../../mixins/base
    ../../mixins/nixcache/client.nix
    ../../mixins/server
    ../../mixins/docker
    ../../mixins/agy
    ../../mixins/virtualization
    ../../mixins/tailscale
    ../../mixins/flatpak
    ../../mixins/netboot
    ./jenkins.nix
    ./k3s.nix
  ];
}
