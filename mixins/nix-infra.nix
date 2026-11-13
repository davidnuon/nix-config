{
  config,
  pkgs,
  lib,
  specialArgs,
  builders ? (import ../builders.nix),
  ...
}: let
  cfg = config.mixins.nix-infra;

  # Buildbot
  workerPassword = "buildbot-local-worker-pass";

  # Hydra
  cfgHydra = config.services.hydra;
  baseDir = "/var/lib/hydra";
  hydraConf = pkgs.writeScript "hydra.conf" cfgHydra.extraConfig;

  # Remote builder
  remoteBuilderCfg = config.programs.remote-builders;
  selectedMachines = map (name: builders.machines.${name}) remoteBuilderCfg.targets;
in {
  imports = [
    specialArgs.buildbot-nix.nixosModules.buildbot-master
    specialArgs.buildbot-nix.nixosModules.buildbot-worker
  ];

  options.mixins.nix-infra = {
    buildbot = {
      enable = lib.mkEnableOption "Buildbot master and worker";
    };

    hydra = {
      enable = lib.mkEnableOption "Hydra Continuous Integration server";
    };

    nixcache = {
      enable = lib.mkEnableOption "Harmonia binary cache server";
      server = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = cfg.nixcache.enable;
          description = "Whether to enable Harmonia binary cache server.";
        };
      };
      client = {
        enable = lib.mkEnableOption "Harmonia binary cache client substituter";
      };
    };

    remote-builder = {
      client = {
        enable = lib.mkEnableOption "remote builder client";
      };
      worker = {
        enable = lib.mkEnableOption "remote builder worker";
      };
    };
  };

  # Programs options for remote-builders fine-tuning
  options.programs.remote-builders = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.remote-builder.client.enable;
      description = "Whether to enable delegating Nix builds to remote builders defined in builders.nix.";
    };

    targets = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames builders.machines));
      default = ["arm"];
      description = "Which builder roles from builders.nix to delegate builds to.";
    };

    sshKey = lib.mkOption {
      type = lib.types.str;
      default = "/etc/ssh/ssh_host_ed25519_key";
      description = "Path to the SSH private key used to authenticate to remote builders.";
    };
  };

  config = lib.mkMerge [
    # Buildbot
    (lib.mkIf cfg.buildbot.enable {
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
    })

    # Hydra
    (lib.mkIf cfg.hydra.enable {
      services.hydra = {
        enable = true;
        hydraURL = lib.mkDefault "http://localhost:3000";
        notificationSender = lib.mkDefault "hydra@localhost";
        useSubstitutes = true;
      };

      networking.firewall.allowedTCPPorts = [3000];

      # Fix upstream NixOS bug: missing `--` before `createuser` and `createdb -O` causes
      # `runuser` to treat `-O` as a runuser flag: "runuser: invalid option -- 'O'"
      systemd.services.hydra-init.preStart = lib.mkForce ''
        mkdir -p ${baseDir}
        chown hydra:hydra ${baseDir}
        chmod 0750 ${baseDir}

        ln -sf ${hydraConf} ${baseDir}/hydra.conf

        mkdir -m 0700 ${baseDir}/www || true
        chown hydra-www:hydra ${baseDir}/www

        mkdir -m 0700 ${baseDir}/queue-runner || true
        mkdir -m 0750 ${baseDir}/build-logs || true
        mkdir -m 0750 ${baseDir}/runcommand-logs || true
        chown hydra-queue-runner:hydra \
          ${baseDir}/queue-runner \
          ${baseDir}/build-logs \
          ${baseDir}/runcommand-logs

        if ! [ -e ${baseDir}/.db-created ]; then
          runuser -u ${config.services.postgresql.superUser} -- ${config.services.postgresql.package}/bin/createuser hydra || true
          runuser -u ${config.services.postgresql.superUser} -- ${config.services.postgresql.package}/bin/createdb -O hydra hydra || true
          touch ${baseDir}/.db-created
        fi
        echo "create extension if not exists pg_trgm" | runuser -u ${config.services.postgresql.superUser} -- ${config.services.postgresql.package}/bin/psql hydra

        if [ ! -e ${cfgHydra.gcRootsDir} ]; then
          # Move legacy roots directory.
          if [ -e /nix/var/nix/gcroots/per-user/hydra/hydra-roots ]; then
            mv /nix/var/nix/gcroots/per-user/hydra/hydra-roots ${cfgHydra.gcRootsDir}
          fi

          # Move legacy hydra-www roots.
          if [ -e /nix/var/nix/gcroots/per-user/hydra-www/hydra-roots ]; then
            find /nix/var/nix/gcroots/per-user/hydra-www/hydra-roots/ -type f -print0 \
              | xargs -0 -I{} mv {} ${cfgHydra.gcRootsDir}
            rmdir /nix/var/nix/gcroots/per-user/hydra-www/hydra-roots
          fi

          chown hydra:hydra ${cfgHydra.gcRootsDir}
          chmod 2775 ${cfgHydra.gcRootsDir}
        fi
      '';

      systemd.services.hydra-trigger-x86 = {
        description = "Hydra Trigger: eval all-x86 job";
        after = ["hydra-server.service" "network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          User = "hydra";
          ExecStart = ''
            ${pkgs.curl}/bin/curl -f -s -X POST \
              -H "Accept: application/json" \
              http://localhost:3000/jobset/nix-config/main/eval || true
          '';
        };
      };
    })

    # Harmonia cache server
    (lib.mkIf cfg.nixcache.server.enable {
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
    })

    # Harmonia cache client substituter
    (lib.mkIf cfg.nixcache.client.enable {
      nix.settings = {
        extra-substituters = [
          "http://${builders.cacheHost}:${toString builders.cachePort}"
        ];
        extra-trusted-public-keys = [
          builders.cachePublicKey
        ];
      };
    })

    # Remote builder client
    (lib.mkIf remoteBuilderCfg.enable {
      nix.distributedBuilds = true;
      nix.extraOptions = ''
        builders-use-substitutes = true
      '';

      programs.ssh.knownHosts = builtins.listToAttrs (
        map (m: {
          name = m.hostName;
          value = {
            publicKey = m.sshHostKey;
          };
        })
        (lib.filter (m: (m.sshHostKey or null) != null) selectedMachines)
      );

      nix.buildMachines =
        map (m: {
          inherit
            (m)
            hostName
            systems
            maxJobs
            speedFactor
            ;
          supportedFeatures = m.supportedFeatures or [];
          mandatoryFeatures = m.mandatoryFeatures or [];
          sshUser = "nixremote";
          sshKey = remoteBuilderCfg.sshKey;
        })
        selectedMachines;
    })

    # Remote builder worker
    (lib.mkIf cfg.remote-builder.worker.enable {
      users.users.nixremote = {
        isNormalUser = true;
        description = "Nix remote builder user";
        openssh.authorizedKeys.keys = builders.coordinatorAuthorizedKeys;
      };

      nix.settings.trusted-users = [
        "root"
        "nixremote"
      ];
    })
  ];
}
