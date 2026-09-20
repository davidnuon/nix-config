{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.sunshine = {
    enable = lib.mkEnableOption "Sunshine game streaming server";
  };

  config = lib.mkIf config.mixins.sunshine.enable {
    services.sunshine = {
      enable = true;
      autoStart = true; # optional: starts Sunshine automatically on login
      capSysAdmin = true;
      openFirewall = true;
    };

    # Allow members of the 'input' group to access /dev/uinput
    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
    '';
  };
}
