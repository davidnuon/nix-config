{...}: {
  nixpkgs.overlays = [
    (import ../pkgs)
  ];

  imports = [
    ./aero
    ./affinity
    ./agy
    ./artcraft
    ./base
    ./buildbot
    ./distrobox
    ./docker
    ./flatpak
    ./garage
    ./gaming.nix
    ./guix
    ./hydra
    ./input-remapper
    ./kde
    ./libreoffice
    ./nixcache
    ./officecraft
    ./patchy
    ./photogimp
    ./remote-builder
    ./remote-desktop
    ./server
    ./tailscale
    ./ts100-driver
    ./virtualbox
    ./virtualization
    ./waydroid
    ./xosview
  ];
}
