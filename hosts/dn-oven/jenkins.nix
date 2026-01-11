{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [];

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
