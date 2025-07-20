{specialArgs, ...}:
specialArgs.nixpkgs-2505.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    (import "${specialArgs.home-manager-2505}/nixos")
    (import ../../users/davidnuon {stateVersion = "25.05";})

    "${specialArgs.nixos-hardware}/framework/13-inch/7040-amd"

    ../../mixins/kde
    ../../mixins/steam
    ../../mixins/base
    ../../mixins/docker
    ../../mixins/remote-desktop
    ../../mixins/virtualization
    ../../mixins/tailscale
    ../../mixins/flatpak
    ../../mixins/libreoffice
    ../../mixins/godot
  ];
}
