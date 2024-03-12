{
  config,
  pkgs,
  ...
}: {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    tmux
    htop
    git
    nettools
    gnumake
    alejandra
    python311

    zellij
    btop

    usbutils
    pciutils
    hwinfo
   
    dnsutils
  ];
}
