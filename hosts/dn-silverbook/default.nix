{specialArgs, ...}:
let 
  homeManageStateVersion = builtins.replaceStrings ["pre-git"] [""] specialArgs.nixpkgs.lib.version;
in 
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    (import "${specialArgs.home-manager-2411}/nixos")
            (import ../../users/davidnuon {stateVersion = homeManageStateVersion;})

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
