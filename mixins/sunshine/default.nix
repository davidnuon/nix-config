{
  config,
  pkgs,
  lib,
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

  services.sunshine.applications = {
    env = {
      PATH = "$(PATH):$(HOME)/.local/bin";
    };
    apps = [
        {
          name = "Launch BigSteam";
          detached = [
            "${lib.getExe pkgs.steam} steam://open/bigpicture"
          ];
					undo = "${lib.getExe pkgs.steam} steam://close/bigpicture";
          auto-detach = true;
          wait-all = true;
          exit-timeout = 5;
          image-path = "";
        }
    ];
  };
}
