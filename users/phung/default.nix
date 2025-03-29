{stateVersion}: {
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./home-manager
  ];

  users.users.phung = {
    isNormalUser = true;
    description = "Phung";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  home-manager.users.davidnuon.home.stateVersion = stateVersion;
}
