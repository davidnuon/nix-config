{specialArgs, ...}:
let 
  homeManageStateVersion = builtins.replaceStrings ["pre-git"] [""] specialArgs.nixpkgs.lib.version;
in 
specialArgs.nixpkgs-unstable.lib.nixosSystem {
  inherit specialArgs;
  system = "aarch64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix

    (import "${specialArgs.home-manager-2411}/nixos")
            (import ../../users/davidnuon {stateVersion = homeManageStateVersion;})

    ../../mixins/base
    ../../mixins/tailscale
    ../../mixins/docker
    ../../mixins/flatpak

    # Below two modules stolen from @jmbaur
    # https://github.com/jmbaur/homelab/tree/main/nixos-modules/hardware/
    ./blackrock
    ./qualcomm
  ];
}
