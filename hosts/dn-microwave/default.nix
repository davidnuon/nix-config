{specialArgs, ...}:
specialArgs.nixpkgs-unstable.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    (import "${specialArgs.home-manager-2411}/nixos")
    (import ../../users/davidnuon {stateVersion = "25.05";})

    ../../mixins/base

    # Below two modules stolen from @jmbaur
    # https://github.com/jmbaur/homelab/tree/main/nixos-modules/hardware/
    ./blackrock
    ./qualcomm
  ];
}
