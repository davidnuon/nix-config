{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}: let
  workerPassword = "buildbot-local-worker-pass";
in {
  imports = [
    specialArgs.buildbot-nix.nixosModules.buildbot-master
    specialArgs.buildbot-nix.nixosModules.buildbot-worker
  ];

  options.mixins.buildbot = {
    enable = lib.mkEnableOption "Buildbot master and worker";
  };

  config = lib.mkIf config.mixins.buildbot.enable {
    services.buildbot-nix.master = {
      enable = true;
      domain = lib.mkDefault "localhost";
      authBackend = "none";
      allowUnauthenticatedControl = true;
      enableNginx = true;
      buildSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      workersFile = pkgs.writeText "workers.json" (builtins.toJSON [
        {
          name = config.networking.hostName;
          pass = workerPassword;
          cores = 8;
        }
      ]);

      pullBased = {
        repositories = {
          "davidnuon/nix-config" = {
            url = "https://github.com/davidnuon/nix-config.git";
            defaultBranch = "main";
            pollInterval = 300;
          };
        };
      };
    };

    services.buildbot-nix.worker = {
      enable = true;
      workerPasswordFile = pkgs.writeText "worker-password" workerPassword;
    };

    # Allow access via IP or hostname
    networking.firewall.allowedTCPPorts = [80 443];

    # Fix: Allow buildbot worker to talk to the local Nix daemon
    nix.settings.trusted-users = ["root" "buildbot-worker"];
  };
}
