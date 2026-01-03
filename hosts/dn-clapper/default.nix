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

    (import "${specialArgs.home-manager-2505}/nixos")
            (import ../../users/davidnuon {stateVersion = homeManageStateVersion;})
    (import ../../users/lars {stateVersion = "25.05";})

    ../../mixins/base
    ../../mixins/kde
    ../../mixins/docker
    ../../mixins/tailscale
    ../../mixins/flatpak
  ];
}
