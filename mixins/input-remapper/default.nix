{
  config,
  pkgs,
  ...
}: {
  imports = [];

  services.input-remapper.enable = true;

  # Clean up stale IPC pipe symlinks on boot to prevent PID reuse collisions
  systemd.tmpfiles.rules = [
    "R! /tmp/input-remapper-*"
  ];
}
