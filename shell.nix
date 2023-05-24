{pkgs ? import <nixpkgs> {}}: let
  USER_HOME = builtins.getEnv "HOME";
  joinStr = sep: acc: _list:
    with pkgs.lib.lists; let
      _left = foldr (a: b: a + sep + b) acc (init _list);
      _right = last _list;
    in
      _left + _right;
in {
  default = pkgs.mkShell {
    NIX_PATH = joinStr ":" "" [
      "${USER_HOME}/.nix-defexpr/channels"
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=./configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
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
