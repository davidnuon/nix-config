{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    (import "${specialArgs.home-manager}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})
    ./x13s-nixos/module.nix

    ../../mixins
    {
      mixins.base.enable = true;
      mixins.aero.enable = true;
      mixins.docker.enable = true;
      mixins.tailscale.enable = true;
      mixins.xosview.enable = true;
      mixins.flatpak.enable = true;
      mixins.waydroid.enable = true;
      mixins.forge-mtg.enable = true;
    }

    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
