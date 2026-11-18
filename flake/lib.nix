{
  nixpkgs,
  inputs,
  ...
}: let
  inherit
    (builtins)
    listToAttrs
    map
    readDir
    attrNames
    ;
  inherit (inputs.nixpkgs) lib;
  stateVersion = builtins.head (builtins.match "([0-9]+\\.[0-9]+).*" nixpkgs.lib.version);
  extendedSpecialArgs =
    inputs
    // {
      inherit stateVersion;
      hosts = import ../hosts.nix;
      builders = import ../builders.nix;
    };
  mkConfigurationsFrom = dir: let
    entries = lib.filterAttrs (name: type: type == "directory" && name != "vm") (readDir dir);
  in
    lib.genAttrs (attrNames entries) (name:
      import (dir + "/${name}") {
        specialArgs = extendedSpecialArgs;
      });
in {
  inherit extendedSpecialArgs mkConfigurationsFrom stateVersion;
}
