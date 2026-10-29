{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}: let
  unstable-pkgs = import specialArgs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
    config.problems.handlers = {
      posthog.broken = "warn"; # or "ignore"
    };
  };
in {
  networking.firewall.allowedTCPPorts = [1337];

  #   services.open-webui = {
  #     enable = true;
  #     openFirewall = true;
  #     host = "0.0.0.0";
  #     port = 1337;
  # #    package = unstable-pkgs.open-webui;
  #   };

  services.ollama = {
    enable = true;
    # Optional: preload models, see https://ollama.com/library
    loadModels = [
      "qwen2.5-coder:7b"
      "hermes3:latest"
      "nomic-embed-text"
      "llama3.2:3b"
      "deepseek-r1:1.5b"
      "gpt-oss"
    ];
    openFirewall = true;
    package = unstable-pkgs.ollama-vulkan;
    host = "0.0.0.0";
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "-1";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "2";
      OLLAMA_VULKAN = "1";
    };
  };

  environment.systemPackages = with unstable-pkgs; [
    opencode
  ];
}
