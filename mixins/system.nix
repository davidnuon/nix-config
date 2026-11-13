{
  config,
  pkgs,
  lib,
  options,
  ...
}: let
  cfg = config.mixins.system;
in {
  options.mixins.system = {
    tailscale = {
      enable = lib.mkEnableOption "Tailscale";
    };

    garage = {
      enable = lib.mkEnableOption "Garage S3 storage service";
    };
  };

  config = lib.mkMerge [
    # Tailscale
    (lib.mkIf cfg.tailscale.enable {
      networking.firewall.checkReversePath = "loose";
      services.tailscale.enable = true;
    })

    # Garage
    (lib.mkIf cfg.garage.enable {
      services.garage = {
        enable = true;
        package = lib.mkDefault pkgs.garage;

        settings = {
          replication_factor = lib.mkDefault 1;

          rpc_bind_addr = lib.mkDefault "[::]:3901";
          rpc_secret_file =
            if (options ? sops && config.sops.secrets ? "garage-rpc-secret")
            then lib.mkDefault config.sops.secrets."garage-rpc-secret".path
            else lib.mkDefault "/var/lib/garage/rpc_secret";

          s3_api = {
            api_bind_addr = lib.mkDefault "[::]:3900";
            s3_region = lib.mkDefault "garage";
            root_domain = lib.mkDefault ".s3.garage.localhost";
          };

          s3_web = {
            bind_addr = lib.mkDefault "[::]:3902";
            root_domain = lib.mkDefault ".web.garage.localhost";
          };

          admin = {
            api_bind_addr = lib.mkDefault "[::]:3903";
          };
        };
      };

      systemd.services.garage.preStart = lib.mkAfter ''
        if [ ! -f /var/lib/garage/rpc_secret ] && [ "${toString config.services.garage.settings.rpc_secret_file}" = "/var/lib/garage/rpc_secret" ]; then
          mkdir -p /var/lib/garage
          ${pkgs.openssl}/bin/openssl rand -hex 32 > /var/lib/garage/rpc_secret
          chmod 600 /var/lib/garage/rpc_secret
        fi
      '';

      networking.firewall.allowedTCPPorts = [
        3900 # S3 API
        3901 # RPC
        3902 # S3 Web
        3903 # Admin API
      ];
    })
  ];
}
