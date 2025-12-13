{specialArgs, ...}:
specialArgs.nixpkgs-2505.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    (import "${specialArgs.home-manager-2505}/nixos")
    (import ../../users/davidnuon {stateVersion = "25.05";})
    ./x13s-nixos/module.nix

    ../../mixins/base
    ../../mixins/docker
    ../../mixins/tailscale
    ../../mixins/xosview
    ../../mixins/flatpak
    ../../mixins/waydroid
    ../../mixins/kde
    ../../mixins/forge-mtg
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
