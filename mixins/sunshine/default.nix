{
  config,
  pkgs,
  ...
}: {
  imports = [];

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
}
