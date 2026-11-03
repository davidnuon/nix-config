{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    (import "${specialArgs.home-manager}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})

    specialArgs.disko.nixosModules.disko
    ./disk-config.nix

    ./nvidia.nix
    ./prime.nix
    ./proart.nix

    ../../mixins/base
    ../../mixins/nixcache/client.nix

    ../../mixins/docker

    ../../mixins/remote-desktop
    ../../mixins/virtualization
    ../../mixins/flatpak

    ../../mixins/tailscale

    ../../mixins/lutris
    ../../mixins/battlenet
    ../../mixins/steam
    ../../mixins/forge-mtg
    ../../mixins/xivlauncher
    ../../mixins/godot
    ../../mixins/artcraft

    ../../mixins/patchy
    ../../mixins/affinity
    ../../mixins/officecraft
    ../../mixins/photogimp
    ../../mixins/libreoffice

    ../../mixins/agy
  ];
}
