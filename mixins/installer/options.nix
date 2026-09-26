{lib, ...}: {
  options.installer = {
    menuEntries = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Name displayed in the GRUB boot menu";
          };
          dtb = lib.mkOption {
            type = lib.types.str;
            description = "Relative path to DTB file within the boot root, e.g. dtbs/qcom/...";
          };
          extraParams = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Extra kernel parameters specific to this hardware target";
          };
          smbiosModel = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "SMBIOS product/model string to match for auto-selecting default menu entry";
          };
        };
      });
      default = [];
      description = "List of hardware menu entries for multi-platform installers";
    };
  };
}
