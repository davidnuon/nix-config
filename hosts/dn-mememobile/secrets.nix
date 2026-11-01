{
  config,
  pkgs,
  ...
}: {
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    secrets = {
      "harmonia-secret-key" = {
        owner = "root";
        mode = "0400";
        restartUnits = ["harmonia.service"];
      };
    };
  };
}
