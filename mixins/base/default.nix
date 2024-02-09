{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./core.nix
    ./packages.nix
    ./desktop-core.nix
    ./desktop-gnome.nix
    ./desktop-lang-jp.nix
    ./unstable.nix
  ];
}
