{
  config,
  pkgs,
  ...
}: {
  imports = [];

  environment.systemPackages = with pkgs; [
    godot_422
  ];

  nixpkgs.overlays = [
    (final: prev: {
      godot_422 = prev.godot_4.overrideAttrs (old: {
        version = "4.2.2-stable";
        commitHash = "15073afe3856abd2aa1622492fe50026c7d63dc1";
        src = pkgs.fetchFromGitHub {
          owner = "godotengine";
          repo = "godot";
          rev = "15073afe3856abd2aa1622492fe50026c7d63dc1";
          hash = "sha256-anJgPEeHIW2qIALMfPduBVgbYYyz1PWCmPsZZxS9oHI=";
        };
      });
    })
  ];
}
