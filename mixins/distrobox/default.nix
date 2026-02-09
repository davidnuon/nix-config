{
  config,
  pkgs,
  ...
}: {
  imports = [];

  environment.systemPackages = [pkgs.distrobox];
}
