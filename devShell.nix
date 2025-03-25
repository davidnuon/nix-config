{
  system,
  specialArgs,
  ...
}: {
  default = let
    pkgs = import specialArgs.nixpkgs-2411 {
      system = "${system}";
    };
  in
    pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        nix
        vim
        home-manager
        git
        gnumake
        alejandra
      ];
    };
}
