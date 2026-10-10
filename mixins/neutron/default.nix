{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.neutron;
  neutron = pkgs.callPackage ./package.nix {};
in {
  options.programs.neutron = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable the Neutron compatibility engine for Adobe creative software.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = neutron;
      description = "The Neutron package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      pkgs.cabextract
    ];

    # 32-bit graphics and system libraries required for Wine and 32-bit Adobe helper daemons
    hardware.graphics = {
      enable = lib.mkDefault true;
      enable32Bit = lib.mkDefault true;
    };

    # Enable nix-ld so dynamically linked helpers executed outside the FHS wrapper can also run
    programs.nix-ld.enable = lib.mkDefault true;
  };
}
