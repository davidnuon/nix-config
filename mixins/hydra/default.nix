{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.hydra;
  baseDir = "/var/lib/hydra";
  hydraConf = pkgs.writeScript "hydra.conf" cfg.extraConfig;
in {
  options.mixins.hydra = {
    enable = lib.mkEnableOption "Hydra Continuous Integration server";
  };

  config = lib.mkIf config.mixins.hydra.enable {
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

      if [ ! -e ${cfg.gcRootsDir} ]; then
        # Move legacy roots directory.
        if [ -e /nix/var/nix/gcroots/per-user/hydra/hydra-roots ]; then
          mv /nix/var/nix/gcroots/per-user/hydra/hydra-roots ${cfg.gcRootsDir}
        fi

        # Move legacy hydra-www roots.
        if [ -e /nix/var/nix/gcroots/per-user/hydra-www/hydra-roots ]; then
          find /nix/var/nix/gcroots/per-user/hydra-www/hydra-roots/ -type f -print0 \
            | xargs -0 -I{} mv {} ${cfg.gcRootsDir}
          rmdir /nix/var/nix/gcroots/per-user/hydra-www/hydra-roots
        fi

        chown hydra:hydra ${cfg.gcRootsDir}
        chmod 2775 ${cfg.gcRootsDir}
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
  };
}
