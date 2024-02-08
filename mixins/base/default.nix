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
    ./user-davidnuon.nix
  ];
}
