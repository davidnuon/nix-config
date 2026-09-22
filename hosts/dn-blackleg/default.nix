{specialArgs, ...}:
specialArgs.nixpkgs-x13s.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    (import "${specialArgs.home-manager-x13s}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})
    ./x13s-nixos/module.nix
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
