{
  config,
  lib,
  pkgs,
  ...
}: {
  services.open-webui = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
    port = 8080;
    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
    };
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    openFirewall = true;
    host = "0.0.0.0";
    loadModels = [
      "qwen2.5-coder:3b"
      "llama3.2:3b"
      "hermes3:latest"
      "nomic-embed-text"
    ];
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "-1";
      OLLAMA_FLASH_ATTENTION = "0";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "1";
    };
  };

  systemd.services.ollama.serviceConfig.SupplementaryGroups = ["render" "video"];

  environment.systemPackages = with pkgs; [
    opencode
  ];
}
