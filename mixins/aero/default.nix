{
  config,
  pkgs,
  specialArgs,
  ...
}: {
  imports = [
    specialArgs.aerothemeplasma-nix.nixosModules.aerothemeplasma-nix
  ];
 # boot.plymouth.enable = true;
#  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "aerothemeplasma"; # for x11, append x11

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
}
