{
  config,
  lib,
  pkgs,
  builders ? (import ../../builders.nix),
  ...
}: let
  cfg = config.mixins.nixcache.client;
in {
  options.mixins.nixcache = {
    client = {
      enable = lib.mkEnableOption "Harmonia binary cache client substituter";
    };
  };

  options.mixins.nixcache-client = {
    enable = lib.mkEnableOption "Harmonia binary cache client substituter";
  };

  config = lib.mkIf (cfg.enable || config.mixins.nixcache-client.enable) {
    nix.settings = {
      extra-substituters = [
        "http://${builders.cacheHost}:${toString builders.cachePort}"
      ];
      extra-trusted-public-keys = [
        builders.cachePublicKey
      ];
    };
  };
}
