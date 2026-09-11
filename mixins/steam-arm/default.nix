{
  config,
  pkgs,
  lib,
  ...
}: let
  box32 = pkgs.box64.overrideAttrs (old: {
    pname = "box32";
    cmakeFlags = old.cmakeFlags ++ [
      "-DBOX32:BOOL=TRUE"
      "-DBOX32_BINFMT:BOOL=TRUE"
    ];
    doCheck = false;
    doInstallCheck = false;
  });

  nativeBox64Libs = with pkgs; [
    # Audio
    alsa-lib
    libpulseaudio
    libsndfile
    openal
    # SDL
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    SDL2_net
    SDL
    SDL_image
    SDL_mixer
    SDL_ttf
    SDL_net
    # Graphics & Display
    libGL
    libGLU
    mesa
    vulkan-loader
    wayland
    libdrm
    libvdpau
    libva
    # X11 & extensions
    libX11
    libXext
    libXrandr
    libXrender
    libxcb
    libXfixes
    libXcomposite
    libXcursor
    libXdamage
    libXi
    libXinerama
    libXScrnSaver
    libXtst
    libXxf86vm
    libXft
    libXpm
    libXmu
    libXt
    libSM
    libICE
    libxshmfence
    libXpresent
    libxkbfile
    libxkbcommon
    # Fonts & Rendering
    fontconfig
    freetype
    pango
    cairo
    atk
    gdk-pixbuf
    gtk2
    gtk3
    glib
    # Formats & Compression
    zlib
    bzip2
    xz
    zstd
    libpng
    libjpeg
    libxml2
    libxslt
    libvorbis
    libogg
    # System & Auth
    dbus
    util-linux
    nspr
    nss
    krb5
  ];

  box64Wrapper = pkgs.writeShellScript "box64-wrapper" ''
    if [ -z "$BOX64_RCFILE" ]; then
      if [ -f /etc/box64.box64rc ]; then
        export BOX64_RCFILE=/etc/box64.box64rc
      else
        export BOX64_RCFILE="${box32.src}/system/box64.box64rc"
      fi
    fi
    export BOX64_LD_LIBRARY_PATH="/run/opengl-driver/lib:${lib.makeLibraryPath nativeBox64Libs}''${BOX64_LD_LIBRARY_PATH:+:$BOX64_LD_LIBRARY_PATH}"
    exec ${box32}/bin/box64 "$@"
  '';

  steamFhs = pkgs.buildFHSEnv {
    name = "steam-box64-fhs";

    targetPkgs = p:
      nativeBox64Libs
      ++ (with p; [
        box32
        bash
        coreutils
        curl
        gnutar
        glibc
        libgcc
        gnutls
        udev
        file
        pciutils
        usbutils
        xdg-utils
        zenity
        findutils
        which
        strace
        gdb
        procps
        iproute2
        nettools
        cups
        pipewire
      ]);

    extraOutputsToInstall = ["lib" "bin"];

    profile = ''
      if [ -f /etc/box64.box64rc ]; then
        export BOX64_RCFILE=/etc/box64.box64rc
      else
        export BOX64_RCFILE="${box32.src}/system/box64.box64rc"
      fi
      export STEAMOS=1
      export STEAM_RUNTIME=1
      export PROTON_USE_WOW64=1
      export DBUS_FATAL_WARNINGS=0
      export SDL_JOYSTICK_DISABLE_UDEV=1
      export GTK_IM_MODULE='xim'
      export LIBGL_DRIVERS_PATH=/run/opengl-driver/lib/dri
      export __EGL_VENDOR_LIBRARY_DIRS=/run/opengl-driver/share/glvnd/egl_vendor.d
      export XDG_DATA_DIRS="/run/opengl-driver/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
      export BOX64_LD_LIBRARY_PATH="/run/opengl-driver/lib:${lib.makeLibraryPath nativeBox64Libs}''${BOX64_LD_LIBRARY_PATH:+:$BOX64_LD_LIBRARY_PATH}"
    '';

    runScript = pkgs.writeShellScript "steam-fhs-inner" ''
      exec "$@"
    '';
  };

  steamWrapper = pkgs.symlinkJoin {
    name = "steam";
    paths = [pkgs.steam-unwrapped];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      rm -f $out/bin/steam
      makeWrapper ${steamFhs}/bin/steam-box64-fhs $out/bin/steam \
        --add-flags "${pkgs.steam-unwrapped}/bin/steam -no-cef-sandbox" \
        --set STEAMOS 1 \
        --set STEAM_OS linux \
        --set STEAM_RUNTIME 1 \
        --set PROTON_USE_WOW64 1 \
        --set DBUS_FATAL_WARNINGS 0
    '';
  };

  steamRunWrapper = pkgs.writeShellScriptBin "steam-run" ''
    set -e
    exec ${steamFhs}/bin/steam-box64-fhs "$@"
  '';

  steamcmdWrapper = pkgs.writeShellScriptBin "steamcmd" ''
    set -e
    STEAMROOT="$HOME/.local/share/Steam"
    PATH="$PATH''${PATH:+:}${pkgs.coreutils}/bin"

    if [ ! -e "$STEAMROOT" ]; then
      mkdir -p "$STEAMROOT"/{appcache,config,logs,steamapps/common}
      mkdir -p ~/.steam
      ln -sf "$STEAMROOT" ~/.steam/root
      ln -sf "$STEAMROOT" ~/.steam/steam
    fi

    if [ ! -e "$STEAMROOT/steamcmd.sh" ]; then
      echo "Downloading steamcmd..."
      mkdir -p "$STEAMROOT"
      ${pkgs.curl}/bin/curl -sSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | ${pkgs.gnutar}/bin/tar -xz -C "$STEAMROOT"
    fi

    exec ${steamFhs}/bin/steam-box64-fhs "$STEAMROOT/steamcmd.sh" "$@"
  '';
in {
  boot.binfmt.preferStaticEmulators = false;

  boot.binfmt.registrations = {
    "x86_64-linux" = {
      interpreter = "${box64Wrapper}";
      magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
      mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
      wrapInterpreterInShell = false;
      preserveArgvZero = false;
      openBinary = false;
    };
    "i386-linux" = {
      interpreter = "${box64Wrapper}";
      magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x03\x00'';
      mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
      wrapInterpreterInShell = false;
      preserveArgvZero = false;
      openBinary = false;
    };
    "i686-linux" = {
      interpreter = "${box64Wrapper}";
      magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x06\x00'';
      mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
      wrapInterpreterInShell = false;
      preserveArgvZero = false;
      openBinary = false;
    };
  };

  nix.settings.extra-platforms = [
    "x86_64-linux"
    "i686-linux"
    "i386-linux"
  ];

  security.wrappers.bwrap = {
    owner = "root";
    group = "root";
    source = "${pkgs.bubblewrap}/bin/bwrap";
    setuid = true;
  };

  hardware.steam-hardware.enable = true;
  hardware.graphics.enable = true;

  environment.etc."box64.box64rc".source = "${box32.src}/system/box64.box64rc";

  environment.systemPackages = [
    steamWrapper
    steamRunWrapper
    steamcmdWrapper
    box32
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
    ];
}
