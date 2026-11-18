inputs @ {
  self,
  nixpkgs,
  ...
}: let
  systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
  flakeLib = import ./lib.nix {inherit nixpkgs inputs;};
  configuratons = import ./configurations.nix {
    inherit (flakeLib) stateVersion extendedSpecialArgs;
    inherit inputs nixpkgs;
  };
  inherit (configuratons) hostConfigurations x86HostConfigurations aarch64HostConfigurations isoConfigurations;
in {
  overlays.default = import ../pkgs inputs;
  devShells = import ./devShell.nix {inherit inputs systems;};
  nixosConfigurations = hostConfigurations // isoConfigurations;

  hydraJobs = import ./hydra.nix {
    inherit nixpkgs hostConfigurations isoConfigurations;
  };

  packages = import ./packages.nix {
    inherit
      nixpkgs
      x86HostConfigurations
      aarch64HostConfigurations
      isoConfigurations
      ;
  };
}
