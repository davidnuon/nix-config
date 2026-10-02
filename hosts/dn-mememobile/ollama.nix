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
  };
in {
  services.open-webui = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
  };

  services.ollama = {
    enable = true;
    # Optimal models for 16GB VRAM on Pascal:
    # - qwen2.5-coder:14b: Primary daily driver for coding and technical post writing
    # - qwen2.5-coder:7b: Low-latency fast coder
    # - nomic-embed-text: 8k-context dense embedding model for RAG tasks
    # - deepseek-r1:1.5b: Lightweight reasoning
    loadModels = [
      "qwen2.5-coder:14b"
      "qwen2.5-coder:7b"
      "nomic-embed-text"
      "deepseek-r1:1.5b"
    ];
    package = pkgs.ollama-vulkan;
    openFirewall = true;
    host = "0.0.0.0";

    environmentVariables = {
      # Use Vulkan SPIR-V compute backend for Pascal sm_61 GPU
      OLLAMA_VULKAN = "1";
      # Keep up to 2 models resident in VRAM simultaneously
      # (e.g. qwen2.5-coder:14b ~9GB + nomic-embed-text ~274MB)
      # Enables zero-reload RAG queries
      OLLAMA_MAX_LOADED_MODELS = "2";
      # Keep model resident in VRAM for 60 minutes between calls
      OLLAMA_KEEP_ALIVE = "60m";
      # Single concurrent runner avoids splitting 16GB VRAM KV cache
      OLLAMA_NUM_PARALLEL = "1";
      # Enable flash attention for reduced KV cache memory footprint
      OLLAMA_FLASH_ATTENTION = "1";
    };
  };

  environment.systemPackages = with unstable-pkgs; [
    opencode
  ];
}
