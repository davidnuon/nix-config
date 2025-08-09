{specialArgs, ...}:
specialArgs.nixpkgs-2505.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    (import "${specialArgs.home-manager-2505}/nixos")
    (import ../../users/davidnuon {stateVersion = "25.05";})

    ../../mixins/base
    ../../mixins/docker
    ../../mixins/virtualization
    ../../mixins/tailscale
    ../../mixins/flatpak
  ];
}
