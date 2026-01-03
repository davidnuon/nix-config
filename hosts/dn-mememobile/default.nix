{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./nvidia.nix

    (import "${specialArgs.home-manager-2511}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})

    ../../mixins/base
    ../../mixins/docker
    ../../mixins/tailscale
    ../../mixins/flatpak
    ../../mixins/xivlauncher
    ../../mixins/steam
    ../../mixins/kde
    ../../mixins/input-remapper
    ../../mixins/distrobox
    ../../mixins/forge-mtg
    ../../mixins/virtualization
  ];
}
