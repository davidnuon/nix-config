{
  config,
  pkgs,
  ...
}: {
  imports = [];

  services.flatpak.enable = true;
}
