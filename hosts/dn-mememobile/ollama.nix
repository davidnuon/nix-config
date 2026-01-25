{
  config,
  lib,
  pkgs,
  ...
}: {
  services.ollama = {
    enable = true;
    # Optional: preload models, see https://ollama.com/library
    loadModels = ["llama3.2:3b" "deepseek-r1:1.5b" "gpt-oss"];
    acceleration = "vulkan";
  };
}
