{
  config,
  pkgs,
  lib,
  ...
}: {
  services.hercules-ci-agent = {
    enable = true;
    settings = {
      # By default, hercules-ci-agent reads the cluster join token from:
      # /var/lib/hercules-ci-agent/secrets/cluster-join-token.key
      # If using sops-nix, dynamically point to the decrypted secret path:
      clusterJoinTokenPath = lib.mkIf (config ? sops && config.sops.secrets ? "hercules-cluster-join-token")
        config.sops.secrets."hercules-cluster-join-token".path;

      binaryCachesPath = lib.mkIf (config ? sops && config.sops.secrets ? "hercules-binary-caches")
        config.sops.secrets."hercules-binary-caches".path;

      secretsJsonPath = lib.mkIf (config ? sops && config.sops.secrets ? "hercules-secrets-json")
        config.sops.secrets."hercules-secrets-json".path;
    };
  };
}
