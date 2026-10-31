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
      cache.signKeyPaths = lib.mkIf (config ? sops && config.sops.secrets ? "harmonia-secret-key") [
        config.sops.secrets."harmonia-secret-key".path
      ];
    })
    (lib.mkIf (!(options.services.harmonia ? cache)) {
      enable = true;
    })
  ];

  networking.firewall.allowedTCPPorts = [5000];
}
