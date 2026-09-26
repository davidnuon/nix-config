{specialArgs, ...}: let
  rawConfig = specialArgs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    system = "aarch64-linux";
    modules = [
      ../../mixins/installer
      specialArgs.nixos-hardware.nixosModules.lenovo-thinkpad-x13s

      ({
        config,
        pkgs,
        lib,
        ...
      }: let
        wdk2023_syshacks = pkgs.fetchFromGitHub {
          owner = "jglathe";
          repo = "wdk2023_syshacks";
          rev = "359b6c2304516f5ea3f754214625a720cc976ef6";
          hash = "sha256-84QB1jGQwQWEq3gZ3I1vG3DKAxXCC5eKbkZo2egmFuU=";
        };

        blackrockFirmware = [
          (pkgs.runCommand "blackrock-extra-firmware" {} ''
            pushd ${wdk2023_syshacks}/usr/lib/firmware/updates
            find . ! -name "*zst" -type f | while read -r f; do
              dest="$out/lib/firmware/$f"
              mkdir -p "$(dirname "$dest")"
              cp -v "$f" "$dest"
            done
            popd
          '')
          (pkgs.fetchurl {
            name = "wdk2023-firmware";
            url = "https://github.com/armbian/firmware/archive/8dbb28d2ee8fa3d5f67a9d9dbc64c3d2b3b0adac.tar.gz";
            downloadToTemp = true;
            recursiveHash = true;
            postFetch = ''
              tmp=$(mktemp -d)
              tar -C $tmp -xvf $downloadedFile
              mkdir -p $out/lib/firmware/qcom/sc8280xp/microsoft/blackrock
              cp $tmp/*/qcom/sc8280xp/MICROSOFT/DEVKIT23/* $out/lib/firmware/qcom/sc8280xp/microsoft/blackrock
            '';
            hash = "sha256-b8ohFD3IkS0HFqpSmVg9zN/xofmplgiRgihlJPIaugU";
          })
        ];
      in {
        networking.hostName = "dn-installer";

        # Include firmware for both ThinkPad X13s and Windows Dev Kit 2023
        hardware.firmware = blackrockFirmware;

        # Early initrd firmware for Qualcomm Adreno 660 GPU and Dev Kit DSP/display
        boot.initrd.extraFirmwarePaths = [
          "qcom/a660_gmu.bin"
          "qcom/a660_sqe.fw"
          "qcom/sc8280xp/microsoft/blackrock/qcadsp8280.mbn"
          "qcom/sc8280xp/microsoft/blackrock/qccdsp8280.mbn"
          "qcom/sc8280xp/microsoft/blackrock/qcdxkmsuc8280.mbn"
        ];

        # Provide device trees for both platforms in the ISO EFI/boot directory
        boot.loader.systemd-boot.extraFiles = {
          "dtbs/qcom/sc8280xp-lenovo-thinkpad-x13s.dtb" = "${config.boot.kernelPackages.kernel}/dtbs/qcom/sc8280xp-lenovo-thinkpad-x13s.dtb";
          "dtbs/qcom/sc8280xp-microsoft-blackrock.dtb" = "${config.boot.kernelPackages.kernel}/dtbs/qcom/sc8280xp-microsoft-blackrock.dtb";
        };

        # Configure GRUB boot menu entries with hardware auto-detection for both machines
        installer.menuEntries = [
          {
            name = "Lenovo ThinkPad X13s (dn-blackleg)";
            dtb = "dtbs/qcom/sc8280xp-lenovo-thinkpad-x13s.dtb";
            extraParams = "";
            smbiosModel = "21BX";
          }
          {
            name = "Windows Dev Kit 2023 (dn-microwave)";
            dtb = "dtbs/qcom/sc8280xp-microsoft-blackrock.dtb";
            extraParams = "efi=noruntime";
            smbiosModel = "Windows Dev Kit 2023";
          }
        ];

        # Union of kernel modules for ThinkPad X13s and Windows Dev Kit 2023
        boot.initrd.kernelModules = [
          # Storage & PCIe
          "nvme"
          "phy-qcom-qmp-pcie"
          "phy_qcom_qmp_pcie"

          # USB & Type-C controller and PHYs (for virtual optical drives / flash drives)
          "phy_qcom_qmp_usb"
          "phy_qcom_snps_femto_v2"
          "pmic_glink"
          "pmic_glink_altmode"
          "ucsi_glink"
          "typec"
          "typec_ucsi"
          "usb_storage"
          "sd_mod"

          # Input & I2C controllers (keyboards, trackpads, touchscreens)
          "i2c-core"
          "i2c-hid"
          "i2c-hid-of"
          "i2c_hid_of"
          "i2c-qcom-geni"
          "i2c_qcom_geni"

          # Display & GPU clocks / controllers / bridges (X13s eDP + Dev Kit DP/HDMI)
          "dispcc_sc8280xp"
          "gpucc_sc8280xp"
          "phy_qcom_edp"
          "panel-edp"
          "phy-qcom-qmp-combo"
          "gpio_sbu_mux"
          "qrtr"
          "display_connector"
          "aux_bridge"
          "aux_hpd_bridge"
          "msm"
          "leds_qcom_lpg"
          "pwm_bl"
        ];

        boot.kernelModules = config.boot.initrd.kernelModules;

        # Disable TPM2 in initrd to avoid stalls on both Qualcomm platforms
        systemd.tpm2.enable = false;
        boot.initrd.systemd.tpm2.enable = false;

        # Friendly login banner with quick instructions for both machines
        services.getty.helpLine = ''

          =============================================================
            Welcome to the NixOS SC8280XP Multi-Platform Installer!
            Hardware targets:
              - Lenovo ThinkPad X13s (dn-blackleg)
              - Windows Dev Kit 2023 (dn-microwave)

            Quick Installation:
              1. Verify network:
                 ip a
              2. Partition disk with Disko:
                 sudo disko --mode destroy,format,mount ./hosts/<target>/disk-config.nix
              3. Install NixOS:
                 sudo nixos-install --flake .#<target>
          =============================================================
        '';

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
