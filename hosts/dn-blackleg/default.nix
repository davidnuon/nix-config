{specialArgs, ...}:
specialArgs.nixpkgs-2511.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    (import "${specialArgs.home-manager-2511}/nixos")
    (import ../../users/davidnuon {stateVersion = "25.11";})
    ./x13s-nixos/module.nix

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
