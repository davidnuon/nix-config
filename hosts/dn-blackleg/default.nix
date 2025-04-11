{specialArgs, ...}:
specialArgs.nixpkgs-2411.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    specialArgs.nixos-x13s.nixosModules.default

    (import "${specialArgs.home-manager-2411}/nixos")
    (import ../../users/davidnuon {stateVersion = "24.11";})

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
