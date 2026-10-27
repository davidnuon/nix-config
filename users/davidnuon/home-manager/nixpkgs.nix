{
  pkgs,
  config,
  lib,
  ...
}: {
  home-manager.users.davidnuon = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnfreePredicate = _: true;
    xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";

    home.sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };
}
