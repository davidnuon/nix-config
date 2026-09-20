{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./nvidia.nix
    ./ollama.nix

    (import "${specialArgs.home-manager}/nixos")
    (import ../../users/davidnuon {stateVersion = specialArgs.cleanVersion;})

    ../../mixins
    {
      mixins.base.enable = true;
      mixins.docker.enable = true;
      mixins.tailscale.enable = true;
      mixins.flatpak.enable = true;
      mixins.xivlauncher.enable = true;
      mixins.steam.enable = true;
      mixins.kde.enable = true;
      mixins.input-remapper.enable = true;
      mixins.distrobox.enable = true;
      mixins.forge-mtg.enable = true;
      mixins.virtualization.enable = true;
    }
  ];
}
