{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.mixins.base.enable {
    environment.systemPackages = with pkgs.unstable; [
      vscode
    ];
  };
}
