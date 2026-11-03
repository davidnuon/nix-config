{
  config,
  lib,
  builders ? (import ../../builders.nix),
  ...
}: {
  users.users.nixremote = {
    isNormalUser = true;
    description = "Nix remote builder user";
    openssh.authorizedKeys.keys = builders.coordinatorAuthorizedKeys;
  };

  nix.settings.trusted-users = [
    "root"
    "nixremote"
  ];
}
