{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./packages.nix
    ./git.nix
    ./gnome.nix
    ./gtk.nix
  ];

  home-manager.users.davidnuon.dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
