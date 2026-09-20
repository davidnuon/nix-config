{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.docker = {
    enable = lib.mkEnableOption "Docker";
  };

  config = lib.mkIf config.mixins.docker.enable {
    virtualisation.docker.enable = true;
  };
}
