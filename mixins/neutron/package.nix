{
  lib,
  stdenv,
  fetchFromGitHub,
  buildFHSEnv,
  writeShellScript,
  makeDesktopItem,
  python3,
  cabextract,
  which,
  curl,
  wget,
  gnutar,
  xz,
  zstd,
  pciutils,
  vulkan-tools,
  coreutils,
  bash,
  gnugrep,
  gnused,
  procps,
  desktop-file-utils,
  shared-mime-info,
  util-linux,
  dbus,
  systemd,
  xdg-utils,
  zenity,
  glibc,
  libGL,
  libglvnd,
  vulkan-loader,
  vulkan-headers,
  wayland,
  libxkbcommon,
  libx11,
  libxcursor,
  libxrandr,
  libxinerama,
  libxi,
  libxext,
  libxfixes,
  libxrender,
  libxcomposite,
  libxdamage,
  libxxf86vm,
  alsa-lib,
  libpulseaudio,
  pipewire,
  fontconfig,
  freetype,
  gnutls,
  openssl,
  cups,
  libusb1,
  udev,
  zlib,
  libpng,
  libjpeg,
  libtiff,
  libxml2,
  lcms2,
  nss,
  nspr,
}: let
  neutron-unwrapped = stdenv.mkDerivation {
    pname = "neutron-unwrapped";
    version = "1.0.0-beta.3";

    src = fetchFromGitHub {
      owner = "Nico-LaFoucate";
      repo = "Neutron";
      rev = "v1.0.0-beta.3";
      hash = "sha256-isa7StiG8OyPVzBY4Fu5qFSsDr+Ilulmi3hXRiytHE4=";
    };

    buildInputs = [python3];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/share/neutron
      cp -r * $out/share/neutron/
      install -Dm755 bin/neutron $out/bin/neutron
      runHook postInstall
    '';
  };

  desktopItem = makeDesktopItem {
    name = "neutron";
    desktopName = "Neutron";
    comment = "Wine-based compatibility engine tuned for creative software on Linux";
    exec = "neutron";
    icon = "neutron";
    terminal = true;
    categories = ["Graphics" "AudioVideo" "Utility"];
  };
in
  buildFHSEnv {
    pname = "neutron";
    version = "1.0.0-beta.3";

    targetPkgs = pkgs:
      with pkgs; [
        neutron-unwrapped
        python3
        cabextract
        which
        curl
        wget
        gnutar
        xz
        zstd
        pciutils
        vulkan-tools
        coreutils
        bash
        gnugrep
        gnused
        procps
        desktop-file-utils
        shared-mime-info
        util-linux
        dbus
        systemd
        xdg-utils
        zenity
      ];

    multiPkgs = pkgs:
      with pkgs; [
        glibc
        libGL
        libglvnd
        vulkan-loader
        vulkan-headers
        wayland
        libxkbcommon
        libx11
        libxcursor
        libxrandr
        libxinerama
        libxi
        libxext
        libxfixes
        libxrender
        libxcomposite
        libxdamage
        libxxf86vm
        alsa-lib
        libpulseaudio
        pipewire
        fontconfig
        freetype
        gnutls
        openssl
        cups
        dbus
        libusb1
        udev
        zlib
        libpng
        libjpeg
        libtiff
        libxml2
        lcms2
        nss
        nspr
      ];

    runScript = writeShellScript "neutron-wrapper" ''
      if [ "$1" = "--run" ]; then
        shift
        exec "$@"
      elif [ "$1" = "--mudhut" ]; then
        shift
        if [ -f "$HOME/.local/share/neutron/bin/mudhut" ]; then
          exec "$HOME/.local/share/neutron/bin/mudhut" "$@"
        else
          exec mudhut "$@"
        fi
      else
        exec neutron "$@"
      fi
    '';

    extraInstallCommands = ''
      mkdir -p $out/share/applications $out/share/icons/hicolor/512x512/apps
      install -Dm644 ${neutron-unwrapped}/share/neutron/assets/collider/collider-512.png $out/share/icons/hicolor/512x512/apps/neutron.png
      install -Dm644 ${desktopItem}/share/applications/* $out/share/applications/

      cat <<'EOF' > $out/bin/neutron-run
      #!/usr/bin/env bash
      exec "$(dirname "$0")/neutron" --run "$@"
      EOF
      chmod +x $out/bin/neutron-run

      cat <<'EOF' > $out/bin/mudhut-fhs
      #!/usr/bin/env bash
      exec "$(dirname "$0")/neutron" --mudhut "$@"
      EOF
      chmod +x $out/bin/mudhut-fhs
    '';

    meta = with lib; {
      description = "Wine-based compatibility engine tuned for professional creative software on Linux";
      homepage = "https://github.com/Nico-LaFoucate/Neutron";
      license = licenses.lgpl21Plus;
      platforms = ["x86_64-linux"];
      mainProgram = "neutron";
    };
  }
