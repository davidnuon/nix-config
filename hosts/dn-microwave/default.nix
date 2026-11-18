{
  nixpkgs,
  disko,
  ...
}:
nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./ollama.nix

    disko.nixosModules.disko
    ./disk-config.nix

    # Below two modules stolen from @jmbaur
    # https://github.com/jmbaur/homelab/tree/main/nixos-modules/hardware/
    ./blackrock
    ./qualcomm
  ];
}
