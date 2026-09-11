{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    (import "${specialArgs.home-manager}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})
    ./x13s-nixos/module.nix

    ../../mixins/base
    ../../mixins/aero
    ../../mixins/docker
    ../../mixins/tailscale
    ../../mixins/xosview
    ../../mixins/flatpak
    ../../mixins/waydroid
    ../../mixins/forge-mtg
    ../../mixins/steam-arm
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
