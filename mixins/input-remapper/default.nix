{
  config,
  pkgs,
  ...
}: {
  imports = [];

  services.input-remapper.enable = true;
}
