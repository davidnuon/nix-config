{
  lib,
  config,
  pkgs,
  ...
}: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      rocmPackages.clr.icd
    ];
    extraPackages32 = [
    ];
  };

  # Load both AMD and NVIDIA video drivers
  services.xserver.videoDrivers = ["nvidia" "amdgpu"];
}
