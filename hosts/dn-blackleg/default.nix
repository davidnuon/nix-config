{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    (import "${specialArgs.home-manager}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})
    specialArgs.nixos-hardware.nixosModules.lenovo-thinkpad-x13s
    # ./wwan.nix

    specialArgs.disko.nixosModules.disko
    ./disk-config.nix

    ../../mixins/base
    ../../mixins/aero
    ../../mixins/agy
    ../../mixins/docker
    ../../mixins/tailscale
    ../../mixins/xosview
    ../../mixins/flatpak
    ../../mixins/waydroid
    ../../mixins/forge-mtg
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
