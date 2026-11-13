{...}: {
  nixpkgs.overlays = [
    (import ../pkgs)
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
