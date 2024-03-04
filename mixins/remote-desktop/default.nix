{pkgs, ...}: {
  imports = [];

  environment.systemPackages = with pkgs; [
    remmina
  ];
}
