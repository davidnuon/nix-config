{
  config,
  pkgs,
  ...
}: {
  imports = [];

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["davidnuon"];
  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true; # virt-manager requires dconf to remember settings
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-top
    pkgs.gnome-boxes
  ];
}