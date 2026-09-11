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
    alsa-lib
    libpulseaudio
    libsndfile
    openal
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
    libGL
    libGLU
    vulkan-loader
    wayland
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
    libSM
    libICE
    fontconfig
    freetype
    libdrm
    libvdpau
    libvorbis
    libogg
    gtk2
    gtk3
    glib
    dbus
    util-linux
  ];

  box64Wrapper = pkgs.writeShellScript "box64-wrapper" ''
    export BOX64_LD_LIBRARY_PATH="/run/opengl-driver/lib:${lib.makeLibraryPath nativeBox64Libs}''${BOX64_LD_LIBRARY_PATH:+:$BOX64_LD_LIBRARY_PATH}"
    exec ${box32}/bin/box64 "$@"
  '';

  steamFhs = pkgs.buildFHSEnv {
    name = "steam-box64-fhs";

    targetPkgs = p:
      with p; [
        box32
        bash
        coreutils
        curl
        glibc
        libgcc
        zlib
        bzip2
        xz
        gnutls
        udev
        libX11
        libXext
        libXfixes
        libXcursor
        libXrandr
        libXrender
        libxcb
        libXi
        libXinerama
        libXScrnSaver
        libSM
        libICE
        libGL
        libGLU
        vulkan-loader
        gtk2
        gtk3
        glib
        pango
        cairo
        freetype
        fontconfig
        dbus
        util-linux
        alsa-lib
        libpulseaudio
        libdrm
        libvdpau
        libvorbis
        libogg
        file
        pciutils
        usbutils
        xdg-utils
        zenity
      ];

    extraOutputsToInstall = ["lib" "bin"];

    profile = ''
      export STEAMOS=1
      export STEAM_RUNTIME=1
      export SDL_JOYSTICK_DISABLE_UDEV=1
      export GTK_IM_MODULE='xim'
      export LIBGL_DRIVERS_PATH=/run/opengl-driver/lib/dri
      export __EGL_VENDOR_LIBRARY_DIRS=/run/opengl-driver/share/glvnd/egl_vendor.d
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
        --add-flags "${pkgs.steam-unwrapped}/bin/steam -no-cef-sandbox -cef-disable-gpu -cef-disable-software-rasterizer" \
        --set STEAMOS 1 \
        --set STEAM_OS linux \
        --set STEAM_RUNTIME 1
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
