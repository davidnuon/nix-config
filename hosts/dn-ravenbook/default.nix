{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    (import "${specialArgs.home-manager}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})

    ../../mixins
    {
      mixins.base.enable = true;
      mixins.aero.enable = true;
      mixins.docker.enable = true;
      mixins.tailscale.enable = true;
      mixins.flatpak.enable = true;
      mixins.guix.enable = true;
    }
  ];
}
