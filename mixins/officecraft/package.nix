{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  dbus,
  libGL,
  vulkan-loader,
  wayland,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxrandr,
  libxkbcommon,
  pname,
  version,
  srcHash,
  cargoHash,
  description,
  extraBins ? [],
  craftFonts,
}: let
  bins = [pname "${pname}-cli"] ++ extraBins;
in
  rustPlatform.buildRustPackage {
    inherit pname version cargoHash;

    src = fetchFromGitHub {
      owner = "storytold";
      repo = pname;
      rev = "v${version}";
      hash = srcHash;
    };

    cargoBuildFlags = lib.concatMap (b: ["-p" b]) bins;

    doCheck = false;

    env = {
      CRAFT_FONTS_DIR = "${craftFonts}";
    };

    nativeBuildInputs = [
      pkg-config
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = [
      stdenv.cc.cc.lib
      alsa-lib
      dbus
      libGL
      vulkan-loader
      wayland
      libx11
      libxcb
      libxcursor
      libxi
      libxrandr
      libxkbcommon
    ];

    runtimeDependencies = [
      dbus
      libGL
      vulkan-loader
      wayland
      libx11
      libxcb
      libxcursor
      libxi
      libxrandr
      libxkbcommon
    ];

    postInstall = ''
      appId="ai.storyteller.${pname}"
      install -Dm644 "packaging/linux/$appId.desktop" "$out/share/applications/$appId.desktop"
      install -Dm644 "packaging/linux/$appId.mime.xml" "$out/share/mime/packages/$appId.xml"
      mkdir -p "$out/share/metainfo"
      sed -e "s/@VERSION@/${version}/g" -e "s/@DATE@/1970-01-01/g" \
        "packaging/linux/$appId.metainfo.xml.in" > "$out/share/metainfo/$appId.metainfo.xml"
      mkdir -p "$out/share/icons"
      cp -R assets/app-icon/hicolor "$out/share/icons/"
    '';

    postFixup = ''
      for bin in $out/bin/*; do
        var="$(basename "$bin" | tr 'a-z-' 'A-Z_')_SKIP_LIB_CHECK"
        if grep -qa "$var" "$bin"; then
          wrapProgram "$bin" --set-default "$var" 1
        fi
      done
    '';

    meta = {
      inherit description;
      homepage = "https://github.com/storytold/${pname}";
      license = with lib.licenses; [mit asl20];
      mainProgram = pname;
      platforms = lib.platforms.linux;
    };
  }
