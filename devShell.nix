{
  system,
  specialArgs,
  ...
}: {
  default = let
    pkgs = import specialArgs.nixpkgs {
      system = "${system}";
    };
    disko = specialArgs.disko.packages.${system}.default;
  in
    pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        nix
        vim
        home-manager
        git
        gnumake
        alejandra
        nixVersions.latest
        nixos-rebuild
        disko
      ];
    };
}
