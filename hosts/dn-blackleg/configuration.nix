{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "dtb=dtbs/x13s-${config.boot.kernelPackages.kernel.version}.dtb"
    "clk_ignore_unused"
    "pd_ignore_unused"
    "arm64.nopauth"
  ];

  boot.initrd.kernelModules = [
    "nvme"
    "phy-qcom-qmp-pcie"

    "i2c-core"
    "i2c-hid"
    "i2c-hid-of"
    "i2c-qcom-geni"

    "leds_qcom_lpg"
    "pwm_bl"
    "qrtr"
    "pmic_glink_altmode"
    "gpio_sbu_mux"
    "phy-qcom-qmp-combo"
    "gpucc_sc8280xp"
    "dispcc_sc8280xp"
    "phy_qcom_edp"
    "panel-edp"
    "msm"
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "dn-blackleg";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Declarative WWAN / 5G modem support
  #  hardware.wwan = {
  #   enable = true;
  #  # apn = "fast.t-mobile.com"; # Change if using another carrier (e.g. "wholesale", "vzwinternet", "broadband")
  #};

  users.users.davidnuon = {
    isNormalUser = true;
    home = "/home/davidnuon";
    extraGroups = ["wheel" "networkmanager"];
  };

  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  services.avahi.enable = true;

  system.stateVersion = "25.11"; # Did you read the comment?
}
