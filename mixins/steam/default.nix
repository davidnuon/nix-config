{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.steam = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    steam-run
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-run"
    ];
}
