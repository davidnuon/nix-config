inputs @ {
  self,
  nixpkgs,
  ...
}: {
  library = import ./lib.nix inputs;
  overlays.default = import ../pkgs inputs;
  devShells = import ./devShell.nix inputs;
  nixosConfigurations = import ../hosts inputs;
  hydraJobs = import ./hydra.nix inputs;
  packages = import ./packages.nix inputs;
}
