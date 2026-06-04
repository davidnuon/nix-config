{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  boot.initrd.kernelModules = ["i915"];
  boot.kernelParams = ["video=DSI-1:panel_orientation=right_side_up" "fbcon=rotate:1"];
}
