{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.remote-builder;
  isMicrowave = config.networking.hostName == "dn-microwave";
in {
  options.services.remote-builder = {
    enable = lib.mkEnableOption "Nix remote building infrastructure" // {default = true;};

    isServer = lib.mkOption {
      type = lib.types.bool;
      default = isMicrowave;
      description = "Whether this machine acts as the build server (dn-microwave) or a build client";
    };

    builderHost = lib.mkOption {
      type = lib.types.str;
      default = "10.0.0.61";
      description = "Static IP or hostname of the remote builder machine";
    };

    builderPublicKey = lib.mkOption {
      type = lib.types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+xBCK0DNbLFkvacsVk6MzX/8AFC7XqFHIBoY18YwEQ";
      description = "SSH host public key for the remote builder";
    };

    sshUser = lib.mkOption {
      type = lib.types.str;
      default = "davidnuon";
      description = "User account used to log into the remote builder";
    };

    sshKey = lib.mkOption {
      type = lib.types.str;
      default = "/root/.ssh/id_ed25519";
      description = "Path to the SSH private key used by the Nix daemon on client machines";
    };

    system = lib.mkOption {
      type = lib.types.str;
      default = "aarch64-linux";
      description = "System architecture of the remote builder";
    };

    maxJobs = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Maximum concurrent build jobs to dispatch to the builder";
    };

    speedFactor = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Relative speed factor of the builder compared to local cores";
    };

    clientPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        # dn-blackleg
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAKjSLkahBk4eD+uwiyEmSVR9NwkgGfqKBmNj1kGxuW davidnuon@dn-blackleg"
      ];
      description = "SSH public keys authorized to perform remote builds on this server";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.isServer {
      # Builder server configuration (dn-microwave)
      nix.settings.trusted-users = ["root" "@wheel" cfg.sshUser];

      users.users.${cfg.sshUser}.openssh.authorizedKeys.keys = cfg.clientPublicKeys;
    })
    (lib.mkIf (!cfg.isServer) {
      # Builder client configuration (e.g. dn-blackleg)
      nix.distributedBuilds = true;

      nix.buildMachines = [
        {
          hostName = cfg.builderHost;
          system = cfg.system;
          protocol = "ssh-ng";
          maxJobs = cfg.maxJobs;
          speedFactor = cfg.speedFactor;
          supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
          mandatoryFeatures = [];
          sshUser = cfg.sshUser;
          sshKey = cfg.sshKey;
        }
      ];

      # Allow builder to substitute pre-built binaries from cache.nixos.org directly
      nix.extraOptions = ''
        builders-use-substitutes = true
      '';

      # Pre-populate known_hosts for the Nix daemon so non-interactive builds don't fail
      programs.ssh.knownHosts.${cfg.builderHost} = {
        publicKey = cfg.builderPublicKey;
      };
    })
  ]);
}
