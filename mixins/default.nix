{inputs ? {}, ...}: {
  nixpkgs.overlays = [
    (import ../pkgs inputs)
  ];

  imports = [
    ./base
    ./creative.nix
    ./desktop.nix
    ./gaming.nix
    ./hardware.nix
    ./nix-infra.nix
    ./server.nix
    ./system.nix
    ./tools.nix
    ./virtualization.nix
  ];
}
