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

    ../../mixins/base
    ../../mixins/docker
    ../../mixins/tailscale
    ../../mixins/flatpak
    ../../mixins/virtualization
  ];
}
