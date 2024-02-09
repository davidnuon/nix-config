{stateVersion}: {
  pkgs,
  config,
  ...
}: {
  imports = [
    ./home-manager
  ];

  users.users.davidnuon = {
    isNormalUser = true;
    description = "David Nuon";
    extraGroups = ["networkmanager" "wheel"];
  };

  home-manager.users.davidnuon.home.stateVersion = stateVersion;
}
