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
      settings = {
        priority = 30; # Adjust lower or higher as needed
      };
      signKeyPaths = lib.mkIf (config ? sops && config.sops.secrets ? "harmonia-secret-key") [
        config.sops.secrets."harmonia-secret-key".path
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [5000];
}
