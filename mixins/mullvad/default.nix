{
  config,
  pkgs,
  ...
}: {
  imports = [];

  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
  networking.resolvconf.enable = false;
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = ["~."];
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.4.4.8"
    ];
    dnsovertls = "true";
  };
}
