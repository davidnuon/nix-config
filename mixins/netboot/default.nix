{
  config,
  pkgs,
  lib,
  ...
}: {
  # 1. Pixiecore DHCP/PXE netboot service
  services.pixiecore = {
    enable = lib.mkDefault true;
    openFirewall = lib.mkDefault true;
    mode = lib.mkDefault "quick";
    quick = lib.mkDefault "xyz";
    dhcpNoBind = lib.mkDefault true;
    port = lib.mkDefault 80;
    statusPort = lib.mkDefault 80;
  };

  # 2. Local HTTP file server for hosting custom ISOs and iPXE scripts
  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts."netboot-isos" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8080;
        }
      ];
      root = "/srv/isos";
      extraConfig = ''
        autoindex on;
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/isos 0755 root root -"
  ];

  networking.firewall.allowedTCPPorts = [8080];

  environment.systemPackages = [
    pkgs.pixiecore
  ];
}
