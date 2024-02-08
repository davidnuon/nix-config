{
  conifg,
  pkgs,
  ...
}: {
  users.users.davidnuon = {
    isNormalUser = true;
    description = "David Nuon";
    extraGroups = ["networkmanager" "wheel"];
  };
}
