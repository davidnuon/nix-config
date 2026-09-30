{specialArgs, ...}: let
  rawConfig = specialArgs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    system = "aarch64-linux";
    modules = [
      ../../mixins/installer
      ../../hosts/dn-microwave/blackrock
      ../../hosts/dn-microwave/qualcomm

      ({
        config,
        lib,
        ...
      }: {
        networking.hostName = "dn-microwave";

        hardware.blackrock.enable = true;

        # Force include default modules so USB host controllers (xhci) and input devices work
        boot.initrd.includeDefaultModules = lib.mkForce true;

        # Place DTB also into systemd-boot.extraFiles so installer mixin can locate it reliably
        boot.loader.systemd-boot.extraFiles = {
          "dtbs/qcom/sc8280xp-microsoft-blackrock.dtb" = "${config.boot.kernelPackages.kernel}/dtbs/qcom/sc8280xp-microsoft-blackrock.dtb";
        };

        # Early initrd modules for USB, display, and storage on Windows Dev Kit 2023 (Blackrock)
        boot.initrd.kernelModules = [
          # Storage & USB PHYs (crucial for iODD ST300 detection)
          "nvme"
          "phy_qcom_qmp_pcie"
          "phy_qcom_qmp_usb"
          "phy_qcom_snps_femto_v2"
          "pmic_glink"
          "pmic_glink_altmode"
          "ucsi_glink"
          "typec"
          "typec_ucsi"

          # Input & display
          "i2c_hid_of"
          "i2c_qcom_geni"
          "dispcc_sc8280xp"
          "gpucc_sc8280xp"
          "phy_qcom_edp"
          "phy_qcom_qmp_combo"
          "gpio_sbu_mux"
          "qrtr"
          "display_connector"
          "aux_bridge"
          "aux_hpd_bridge"
          "msm"
        ];

        # Disable TPM2
        systemd.tpm2.enable = false;
        boot.initrd.systemd.tpm2.enable = false;

        nixpkgs.config.allowUnfree = true;
      })
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
