{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.virtualbox = {
    enable = lib.mkEnableOption "VirtualBox";
  };

  config = lib.mkIf config.mixins.virtualbox.enable {
    virtualisation.virtualbox.host.enable = true;
    virtualisation.virtualbox.guest.enable = true;
  };
}
