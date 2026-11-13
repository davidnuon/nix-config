{
  config,
  pkgs,
  specialArgs,
  lib,
  ...
}: {
  imports = [
    specialArgs.aerothemeplasma-nix.nixosModules.aerothemeplasma-nix
  ];

  options.mixins.aero = {
    enable = lib.mkEnableOption "Aero theme plasma";
  };

  config = lib.mkIf config.mixins.aero.enable {
    services.displayManager.gdm.enable = lib.mkForce false;
    boot.plymouth.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "aerothemeplasma"; # for x11, append x11
    programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

    programs.aeroshell = {
      enable = true;
      fonts.segoe.enable = true;
      polkit.enable = true;
      aerothemeplasma = {
        enable = true;
        sddm.enable = true;
        plymouth.enable = true;
      };
    };
  };
}
