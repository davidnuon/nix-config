args: let
  isOverlay = builtins.isFunction args || (args ? system || args ? stdenv);
  inputs =
    if isOverlay
    then {}
    else args;
  overlay = final: prev: let
    system = prev.stdenv.hostPlatform.system;
  in
    {
      # Local custom packages
      patchy = prev.callPackage ./patchy {};
      ts100-driver = prev.callPackage ./ts100-driver {};
      officecraft = prev.callPackage ./officecraft {};
      nexon-launcher = prev.callPackage ./nexon-launcher {};

      # Unstable nixpkgs instance
      unstable =
        if inputs ? nixpkgs-unstable
        then
          import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          }
        else prev;

      # Antigravity suite
      antigravity = inputs.antigravity-nix.packages.${system}.default or null;
      antigravity-ide = inputs.antigravity-nix.packages.${system}.google-antigravity-ide or null;
      antigravity-cli = inputs.antigravity-nix.packages.${system}.google-antigravity-cli or null;

      # PhotoGIMP
      photo-gimp = inputs.nix-photo-gimp.packages.${system}.default or null;
      photo-gimp-with-plugins = inputs.nix-photo-gimp.packages.${system}.photo-gimp-with-plugins or null;

      # Battle.net package from flake
      battle-net-flake = inputs.nix-battle-net.packages.${system}.battle-net or null;

      # Global msitools check skip for Affinity/Windows tools
      msitools = prev.msitools.overrideAttrs (_: {
        doCheck = false;
      });
    }
    // (
      if inputs ? affinity-nix && inputs.affinity-nix ? overlays.default
      then inputs.affinity-nix.overlays.default final prev
      else {}
    );
in
  if isOverlay
  then overlay args
  else overlay
