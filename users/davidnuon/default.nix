{stateVersion}: {
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./home-manager
  ];

  users.users.davidnuon = {
    isNormalUser = true;
    description = "David Nuon";
    extraGroups = [
      "networkmanager"
      "wheel"

      (lib.mkIf (config.virtualisation.libvirtd.enable) "libvirtd")
      (lib.mkIf (config.virtualisation.virtualbox.host.enable) "vboxusers")
      (lib.mkIf (config.virtualisation.docker.enable) "docker")
    ];
  };

  home-manager.users.davidnuon.home.stateVersion = stateVersion;
}
