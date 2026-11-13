{
  config,
  lib,
  builders ? (import ../../builders.nix),
  ...
}: let
  cfg = config.mixins.remote-builder.worker;
in {
  options.mixins.remote-builder = {
    worker = {
      enable = lib.mkEnableOption "remote builder worker";
    };
  };

  options.mixins.remote-builder-worker = {
    enable = lib.mkEnableOption "remote builder worker";
  };

  config = lib.mkIf (cfg.enable || config.mixins.remote-builder-worker.enable) {
    users.users.nixremote = {
      isNormalUser = true;
      description = "Nix remote builder user";
      openssh.authorizedKeys.keys = builders.coordinatorAuthorizedKeys;
    };

    nix.settings.trusted-users = [
      "root"
      "nixremote"
    ];
  };
}
