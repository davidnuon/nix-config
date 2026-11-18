{
  nixpkgs,
  inputs,
  ...
}: let
  stateVersion = builtins.head (builtins.match "([0-9]+\\.[0-9]+).*" nixpkgs.lib.version);
  extendedSpecialArgs =
    inputs
    // {
      inherit inputs stateVersion;
      hosts = import ../hosts.nix;
      builders = import ../builders.nix;
    };
in {
  inherit extendedSpecialArgs stateVersion;
}
