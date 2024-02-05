{
  config,
  pkgs,
  ...
}: {
  imports = [];
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["davidnuon"];
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.x11 = true;

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true; # virt-manager requires dconf to remember settings
  environment.systemPackages = with pkgs; [virt-manager];
}
