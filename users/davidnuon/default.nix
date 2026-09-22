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
      "networkManager"
      "wheel"

      (lib.mkIf (config.virtualisation.libvirtd.enable) "libvirtd")
      (lib.mkIf (config.virtualisation.virtualbox.host.enable) "vboxusers")
      (lib.mkIf (config.virtualisation.docker.enable) "docker")
      (lib.mkIf (config.services.sunshine.enable) "input")
    ];
  };

  home-manager.users.davidnuon.home.stateVersion = stateVersion;
}
