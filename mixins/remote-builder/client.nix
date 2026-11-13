{
  config,
  lib,
  builders ? (import ../../builders.nix),
  ...
}: let
  cfg = config.programs.remote-builders;
  selectedMachines = map (name: builders.machines.${name}) cfg.targets;
in {
  options.mixins.remote-builder = {
    enable = lib.mkEnableOption "remote builder client";
    client = {
      enable = lib.mkEnableOption "remote builder client";
    };
  };

  options.mixins.remote-builder-client = {
    enable = lib.mkEnableOption "remote builder client";
  };

  options.programs.remote-builders = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.mixins.remote-builder.enable || config.mixins.remote-builder.client.enable || config.mixins.remote-builder-client.enable;
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

  config = lib.mkIf cfg.enable {
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
          supportedFeatures
          mandatoryFeatures
          ;
        sshUser = "nixremote";
        sshKey = cfg.sshKey;
      })
      selectedMachines;
  };
}
