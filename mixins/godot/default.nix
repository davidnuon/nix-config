{
  config,
  pkgs,
  ...
}: {
  imports = [];

  environment.systemPackages = with pkgs; [
    godot_451
  ];

  nixpkgs.overlays = [
    (final: prev: {
      godot_451 = prev.godot_4.overrideAttrs (old: {
        version = "4.5.1-stable";
        commitHash = "f62fdbde15035c5576dad93e586201f4d41ef0cb";
        
        # Get hash with:
        # openssl dgst -sha384 -binary 4.5.1-stable.tar.gz | openssl base64 -A 
        src = pkgs.fetchFromGitHub {
          owner = "godotengine";
          repo = "godot";
          rev = "f62fdbde15035c5576dad93e586201f4d41ef0cb";
          hash = "sha256-G2JsQh2I4QYx5xUyFlNZ8vxMXT63lgojdYND+ASgdDo=";
        };
      });
    })
  ];
}
