{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.amdgpu.opencl.enable = true;

  environment.systemPackages = with pkgs; [lact nvtopPackages.amd];
  systemd.packages = with pkgs; [lact nvtopPackages.amd];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
}
