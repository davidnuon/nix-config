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
  networking.firewall.allowedTCPPorts = [ 1337 ];

  services.open-webui = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
    port = 1337;
    package = unstable-pkgs.open-webui;
  };

  services.ollama = {
    enable = true;
    # Optional: preload models, see https://ollama.com/library
    loadModels = ["llama3.2:3b" "deepseek-r1:1.5b" "gpt-oss"];
    acceleration = "vulkan";
    openFirewall = true;
    host = "0.0.0.0";
  };
}
