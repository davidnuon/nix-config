{
  config,
  pkgs,
  ...
}: {
  imports = [];

  # Tailscale
  networking.firewall.checkReversePath = "loose";
  services.tailscale.enable = true;
}
