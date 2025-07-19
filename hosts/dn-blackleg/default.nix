{specialArgs, ...}:
specialArgs.nixpkgs-2505.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    specialArgs.nixos-x13s.nixosModules.default

    (import "${specialArgs.home-manager-2505}/nixos")
    (import ../../users/davidnuon {stateVersion = "25.05";})

    ../../mixins/base
    ../../mixins/docker
    ../../mixins/tailscale
    ../../mixins/xosview
    ../../mixins/flatpak
    ../../mixins/waydroid
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
