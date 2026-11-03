{
  config,
  pkgs,
  builders ? (import ../../builders.nix),
  ...
}: {
  nix.settings = {
    extra-substituters = [
      "http://${builders.cacheHost}:${toString builders.cachePort}"
    ];
    extra-trusted-public-keys = [
      builders.cachePublicKey
    ];
  };
}
