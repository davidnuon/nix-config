{
  pkgs,
  config,
  lib,
  specialArgs,
  ...
}: {
  imports = [
    ./packages.nix
    ./git.nix
    ./gnome.nix
    ./gtk.nix
    ./hyprland.nix
  ];

  home-manager.users.davidnuon.dconf.settings = lib.mkIf (config.virtualisation.libvirtd.enable) {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
