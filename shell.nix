{pkgs ? import <nixpkgs> {}}: let
in {
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command";
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
