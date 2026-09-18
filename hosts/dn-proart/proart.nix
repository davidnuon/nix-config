{
  lib,
  config,
  pkgs,
  ...
}: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  powerManagement.powertop.enable = true;
  services.asusd.enable = true;
  services.input-remapper.enable = true;

  # Enable the libinput driver framework
  services.libinput = {
    enable = true;

    # Touchpad specific settings
    touchpad = {
      tapping = true;
      naturalScrolling = true; # Set to false if you prefer traditional scrolling
      scrollMethod = "twofinger";
      disableWhileTyping = true;
    };

    # Mouse specific settings
    mouse = {
      accelProfile = "adaptive";
    };
  };
}
