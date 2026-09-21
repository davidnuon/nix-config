{
  pkgs,
  config,
  lib,
  ...
}: {
  home-manager.users.davidnuon = {
    nixpkgs.config.allowUnfree = true;

    xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";

    home.sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };
}
