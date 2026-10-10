{
  config,
  pkgs,
  ...
}: {
  imports = [];

  # Enable CUPS
  services.printing.enable = true;

  # Zeroconf / mDNS resolution for network printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Declaratively configure CUPS printer queues
  hardware.printers = {
    ensurePrinters = [
      {
        name = "Canon_LBP632C";
        location = "Network";
        description = "Canon Color imageCLASS LBP632C";
        deviceUri = "ipp://10.0.0.65:631/ipp/print";
        model = "everywhere";
        ppdOptions = {
          PageSize = "Letter";
        };
      }
      {
        name = "HP_Color_LaserJet_MFP_M277dw";
        location = "Network";
        description = "HP Color LaserJet MFP M277dw";
        deviceUri = "ipp://10.0.0.200:631/ipp/print";
        model = "everywhere";
        ppdOptions = {
          PageSize = "Letter";
          ColorModel = "RGB";
        };
      }
    ];
    ensureDefaultPrinter = "Canon_LBP632C";
  };
}
