{
  config,
  pkgs,
  specialArgs,
  ...
}: let
  pkgs = import specialArgs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in {
  environment.systemPackages = with pkgs; [
    gamescope
    mangohud
    (lutris.override {
      extraLibraries = pkgs: [
        wineWowPackages.stable
        gamescope
        winetricks
      ];
      extraPkgs = pkgs: [
        gamescope
      ];
    })
  ];
}
