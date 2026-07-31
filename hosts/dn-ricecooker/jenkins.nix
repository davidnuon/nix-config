{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [80 443 6969];
    allowedUDPPortRanges = [
      {
        from = 4000;
        to = 4007;
      }
      {
        from = 8000;
        to = 8010;
      }
    ];
  };

  services.jenkins.enable = true;
  services.jenkins = {
    port = 6969;
    packages = with pkgs; [
      bash
      coreutils
      findutils
      gnugrep
      gnused
      gawk
      which
      procps
      util-linux
      git
      stdenv
      config.programs.ssh.package
      nix
      docker
    ];
    extraJavaOptions = [
      "-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true"
    ];
  };

  users.users.jenkins = {
    extraGroups = [
      (lib.mkIf (config.virtualisation.docker.enable) "docker")
    ];
  };
}
