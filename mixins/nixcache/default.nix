{
  config,
  pkgs,
  lib,
  options,
  ...
}: {
  imports = [
    ./client.nix
  ];

  options.mixins.nixcache = {
    enable = lib.mkEnableOption "Harmonia binary cache server";
  };

  config = lib.mkIf config.mixins.nixcache.enable {
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
  };
}
