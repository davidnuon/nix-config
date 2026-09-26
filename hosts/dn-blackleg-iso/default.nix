{specialArgs, ...}: let
  rawConfig = specialArgs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    system = "aarch64-linux";
    modules = [
      ../../mixins/installer
      specialArgs.nixos-hardware.nixosModules.lenovo-thinkpad-x13s

      {
        networking.hostName = "dn-blackleg";

        # Extra Qualcomm Adreno GPU firmware for early display initialization
        boot.initrd.extraFirmwarePaths = [
          "qcom/a660_gmu.bin"
          "qcom/a660_sqe.fw"
        ];

        # Early initrd modules for USB, Type-C, display, and storage on ThinkPad X13s
        # Crucial so the iODD ST300 virtual CD-ROM is detected over USB Type-C in stage 1 initrd
        boot.initrd.kernelModules = [
          "nvme"
          "phy-qcom-qmp-pcie"

          # USB & Type-C controller and PHYs
          "phy_qcom_qmp_usb"
          "phy_qcom_snps_femto_v2"
          "pmic_glink"
          "pmic_glink_altmode"
          "ucsi_glink"
          "typec"
          "typec_ucsi"

          # Input & display
          "i2c-core"
          "i2c-hid"
          "i2c-hid-of"
          "i2c-qcom-geni"
          "leds_qcom_lpg"
          "pwm_bl"
          "qrtr"
          "gpio_sbu_mux"
          "phy-qcom-qmp-combo"
          "gpucc_sc8280xp"
          "dispcc_sc8280xp"
          "phy_qcom_edp"
          "panel-edp"
          "msm"
        ];

        # Disable TPM2 in initrd to prevent boot delays or stalls
        systemd.tpm2.enable = false;
        boot.initrd.systemd.tpm2.enable = false;

        nixpkgs.config.allowUnfree = true;
      }
    ];
  };
in
  rawConfig.extendModules {
    modules = [
      {
        system.build.isoImage = specialArgs.nixpkgs.lib.mkForce (rawConfig.config.system.build.installerIso or rawConfig.config.system.build.isoImage);
      }
    ];
  }
