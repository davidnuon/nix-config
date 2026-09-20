{specialArgs, ...}:
specialArgs.nixpkgs-unstable.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    (import "${specialArgs.home-manager}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})

    ../../mixins
    {
      mixins.base.enable = true;
      mixins.tailscale.enable = true;
      mixins.docker.enable = true;
      mixins.flatpak.enable = true;
    }

    # Below two modules stolen from @jmbaur
    # https://github.com/jmbaur/homelab/tree/main/nixos-modules/hardware/
    ./blackrock
    ./qualcomm
  ];
}
