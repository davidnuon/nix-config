{
  lib,
  pkgs,
  fetchFromGitHub,
}: let
  craftFonts = fetchFromGitHub {
    owner = "storytold";
    repo = "craft-fonts";
    rev = "43913056ce82a3fdad0ef69f6b88d1dc922a8104";
    hash = "sha256-u1fC5spekizPXnrK6uiKEZSr2SJOaBF4ffLDbKkywEY=";
  };

  xlibs = {
    libx11 = pkgs.libx11 or pkgs.xorg.libX11;
    libxcb = pkgs.libxcb or pkgs.xorg.libxcb;
    libxcursor = pkgs.libxcursor or pkgs.xorg.libXcursor;
    libxi = pkgs.libxi or pkgs.xorg.libXi;
    libxrandr = pkgs.libxrandr or pkgs.xorg.libXrandr;
  };

  appSpecs = {
    wordcraft = {
      version = "0.7.0";
      srcHash = "sha256-SfrnSydUVuh+3tJ69OINsc1thkubgVh8aEVBfZyXmsM=";
      cargoHash = "sha256-D/CRhDoUbKvz/ev8NKRm2aDEyOA4NL5mdnx+O+iXHRI=";
      description = "WordCraft: an open-source, clean-room word processor in pure Rust";
    };
    figcraft = {
      version = "0.6.0";
      srcHash = "sha256-+tZk3xkpazqOn8oCwOLmFCIDtwfIxrpVgfZkq3xDvTM=";
      cargoHash = "sha256-wCI0BFw5JyMGKkPahNP2yRdrCrWpnX241YeYgRYnNyA=";
      description = "FigCraft: interface design and prototyping in pure Rust";
    };
    deckcraft = {
      version = "0.7.0";
      srcHash = "sha256-MEocLbrEyQ2X+YTxmbsqg69Eox/X7NIFySvuFDMbKV8=";
      cargoHash = "sha256-K02kLzGc/TxFAifSqqpgLWRyM/egWlasQxSjFSEk1Ms=";
      description = "DeckCraft: presentations and slide shows in pure Rust";
    };
    gridcraft = {
      version = "0.7.0";
      srcHash = "sha256-8qlbNJWvONfZ8BvY8fij1QrLwoikFKBgmTiklpu4LOM=";
      cargoHash = "sha256-9PJmE7dLeDIEsnczga1WfWaad1e0YLLh04rJcSyzGwE=";
      description = "GridCraft: an open-source, clean-room spreadsheet in pure Rust";
    };
  };

  packages = lib.mapAttrs (
    pname: spec:
      pkgs.callPackage ./package.nix (xlibs
        // spec
        // {
          inherit pname craftFonts;
        })
  ) appSpecs;
in
  packages
  // {
    default = pkgs.symlinkJoin {
      name = "officecraft";
      paths = builtins.attrValues packages;
    };
  }
