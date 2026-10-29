{
  config,
  lib,
  pkgs,
  ...
}: {
  # NVMe SSD
  fileSystems."/games/steam" = {
    device = "/dev/disk/by-uuid/f5554d50-6328-4a99-b431-39aafe5d502d";
    fsType = "ext4";
  };

  # SATA SSD
  fileSystems."/games/steam-slow" = {
    device = "/dev/disk/by-uuid/5ade1a48-9710-4bb2-b408-a63e0da330b4";
    fsType = "ext4";
  };
}
