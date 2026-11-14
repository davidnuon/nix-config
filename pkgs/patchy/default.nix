{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  python3,
  qt6,
  gtk3,
  gsettings-desktop-schemas,
  libGL,
  fontconfig,
}:

stdenv.mkDerivation rec {
  pname = "patchy";
  version = "1.26";

  src = fetchFromGitHub {
    owner = "SethRobinson";
    repo = "Patchy";
    rev = "v${version}";
    hash = "sha256-HVmTl2c0JGLJULVyPuCDKuo4cGsVKtDoN2oczOaa4gc=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'message(FATAL_ERROR' 'message(WARNING' \
      --replace-fail 'if(NOT CMAKE_CROSSCOMPILING)' 'if(FALSE)'
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
    qt6.wrapQtAppsHook
    qt6.qttools
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtdeclarative
    qt6.qtimageformats
    libGL
    fontconfig
  ];

  cmakeFlags = [
    "-DPATCHY_BUILD_TESTS=OFF"
    "-DPATCHY_REQUIRE_AI_SELECTION=OFF"
    "-DPATCHY_REQUIRE_GEGL=OFF"
  ];

  qtWrapperArgs = [
    "--prefix"
    "XDG_DATA_DIRS"
    ":"
    "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}"
  ];

  passthru = {
    updateScript = ./update.sh;
  };

  meta = with lib; {
    description = "Open-source image editor focused on PSD compatibility and workflows familiar to Adobe Photoshop users";
    homepage = "https://github.com/SethRobinson/Patchy";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "patchy";
  };
}
