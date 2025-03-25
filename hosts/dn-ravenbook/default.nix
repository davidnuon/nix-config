{specialArgs, ...}:
specialArgs.nixpkgs-2405.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    (import "${specialArgs.home-manager-2405}/nixos")
    (import ../../users/davidnuon {stateVersion = "24.05";})

    "${specialArgs.nixos-hardware}/framework/13-inch/7040-amd"

    ../../mixins/base
    ../../mixins/docker
    ../../mixins/tailscale
    ../../mixins/flatpak
    ../../mixins/godot
  ];
}
