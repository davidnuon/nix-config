{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.tailscale = {
    enable = lib.mkEnableOption "Tailscale";
  };

  config = lib.mkIf config.mixins.tailscale.enable {
    networking.firewall.checkReversePath = "loose";
    services.tailscale.enable = true;
  };
}
