{
  config,
  pkgs,
  lib,
  ...
}: {
  options.mixins.steam = {
    enable = lib.mkEnableOption "Steam";
  };

  config = lib.mkIf config.mixins.steam.enable {
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
  };
}
