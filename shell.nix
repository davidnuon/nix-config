{pkgs ? import <nixpkgs> {}}: let
  USER_HOME = builtins.getEnv "HOME";
in {
  default = pkgs.mkShell {
    NIX_PATH = "${USER_HOME}/.nix-defexpr/channels:nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=./configuration.nix:/nix/var/nix/profiles/per-user/root/channels";
    NIX_CONFIG = "extra-experimental-features = nix-command";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git
      gnumake
      alejandra
    ];
  };
}
