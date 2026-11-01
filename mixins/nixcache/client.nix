{
  config,
  pkgs,
  hosts ? (import ../../hosts.nix),
  ...
}: {
  nix.settings = {
    extra-substituters = [
      "http://${hosts.dn-mememobile}:5000"
    ];
    extra-trusted-public-keys = [
      "dn-mememobile-1:WltXjnqq31qus5i6nkhMsk5OCcRbwFM1VwJ7kLmFSQg="
    ];
  };
}
