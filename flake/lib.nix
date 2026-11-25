inputs @ {nixpkgs, ...}: let
  stateVersion = builtins.head (builtins.match "([0-9]+\\.[0-9]+).*" nixpkgs.lib.version);
  extendedSpecialArgs =
    inputs
    // {
      inherit inputs stateVersion;
      hosts = import ../hosts.nix;
      builders = import ../builders.nix;
    };

  mkConfigurationsFrom = dir: let
    inherit (nixpkgs) lib;
    entries = lib.filterAttrs (name: type: type == "directory" && name != "vm") (builtins.readDir dir);
  in
    lib.genAttrs (builtins.attrNames entries) (name:
      import (dir + "/${name}") inputs);
in {
  inherit extendedSpecialArgs stateVersion mkConfigurationsFrom;
}
