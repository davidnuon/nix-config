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

  home-manager.users.lars.dconf.settings = lib.mkIf (config.virtualisation.libvirtd.enable) {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
