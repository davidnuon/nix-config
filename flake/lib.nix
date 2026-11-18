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
  extendedSpecialArgs =
    inputs
    // {
      cleanVersion = builtins.head (builtins.match "([0-9]+\\.[0-9]+).*" nixpkgs.lib.version);
      forge-src = inputs.forge;
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
  inherit extendedSpecialArgs mkConfigurationsFrom;
}
