{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.input-remapper = {
    enable = lib.mkEnableOption "input-remapper service";
  };

  config = lib.mkIf config.mixins.input-remapper.enable {
    services.input-remapper.enable = true;

    # Clean up stale IPC pipe symlinks on boot to prevent PID reuse collisions
    systemd.tmpfiles.rules = [
      "R! /tmp/input-remapper-*"
    ];
  };
}
