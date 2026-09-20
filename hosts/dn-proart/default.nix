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

    ../../mixins
    {
      mixins.steam.enable = true;
      mixins.base.enable = true;
      mixins.docker.enable = true;
      mixins.xivlauncher.enable = true;
      mixins.remote-desktop.enable = true;
      mixins.virtualization.enable = true;
      mixins.tailscale.enable = true;
      mixins.flatpak.enable = true;
      mixins.libreoffice.enable = true;
      mixins.godot.enable = true;
      mixins.agy.enable = true;
    }
  ];
}
