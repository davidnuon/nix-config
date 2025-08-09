{specialArgs, ...}:
specialArgs.nixpkgs-2505.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./nvidia.nix

    (import "${specialArgs.home-manager-2505}/nixos")
    (import ../../users/davidnuon {stateVersion = "25.05";})

    ../../mixins/base
    ../../mixins/docker
    ../../mixins/tailscale
    ../../mixins/flatpak
    ../../mixins/xivlauncher
    ../../mixins/steam
    ../../mixins/input-remapper
  ];
}
