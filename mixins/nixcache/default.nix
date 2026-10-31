{
  config,
  pkgs,
  lib,
  options,
  ...
}: {
  imports = [];

  services.harmonia = lib.mkMerge [
    (lib.mkIf (options.services.harmonia ? cache) {
      cache.enable = true;
    })
    (lib.mkIf (!(options.services.harmonia ? cache)) {
      enable = true;
    })
  ];

  networking.firewall.allowedTCPPorts = [5000];
}
