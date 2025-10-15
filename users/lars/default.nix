{stateVersion}: {
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./home-manager
  ];

  users.users.lars = {
    isNormalUser = true;
    description = "Lars Von Trier";
    extraGroups = [
      "networkmanager"
    ];
  };

  home-manager.users.lars.home.stateVersion = stateVersion;
}
