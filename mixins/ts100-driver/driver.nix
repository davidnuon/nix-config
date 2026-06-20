{
  stdenv,
  lib,
  autoPatchelfHook,
  cups,
}:
stdenv.mkDerivation {
  pname = "ts100-thermal-printer-driver";
  version = "1.0.0";

  # Pulls the source files from the current directory
  src = ./.;

  # nativeBuildInputs are tools executed during the build process
  nativeBuildInputs = [
    autoPatchelfHook
  ];

  # buildInputs provides the shared libraries the binary needs at runtime
  buildInputs = [
    cups
  ];

  # Skip the build phase since 'poss' is a pre-compiled binary
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # CUPS strictly expects filter binaries in /lib/cups/filter
    mkdir -p $out/lib/cups/filter
    install -m 755 poss $out/lib/cups/filter/poss

    # CUPS expects PPD files in /share/cups/model
    mkdir -p $out/share/cups/model
    install -m 644 TS100.ppd $out/share/cups/model/TS100.ppd

    runHook postInstall
  '';

  meta = with lib; {
    description = "CUPS driver and filter for the TS100 thermal receipt printer";
    license = licenses.unfree; # Pre-compiled, closed-source binary
    platforms = ["x86_64-linux"]; # Explicitly locking to x86_64 based on your ldd output
  };
}
