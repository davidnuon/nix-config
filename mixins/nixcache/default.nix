{
  config,
  pkgs,
  lib,
  options,
  ...
}: {
  imports = [];

  services.harmonia = {
    cache = {
      enable = true;
      signKeyPaths = lib.mkIf (config ? sops && config.sops.secrets ? "harmonia-secret-key") [
        config.sops.secrets."harmonia-secret-key".path
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [5000];
}
