{
  lib,
  fetchFromGitHub,
  makeDesktopItem,
  runCommand,
  symlinkJoin,
  writeShellApplication,
  writeText,
  umu-launcher,
  winetricks,
  coreutils,
  curl,
  wget,
  procps,
  gnugrep,
  gnused,
  findutils,
  gamemode,
  pname ? "nexon-launcher",
  location ? "$HOME/.local/share/nix-nexon-launcher",
  useGameMode ? false,
  useWineD3D ? false,
  launcherArgs ? "",
  enableProtonWayland ? false,
  virtualDesktop ? null,
  protonVersion ? null,
  configFile ? null,
  environment ? {},
  preLaunchArgs ? "",
}: let
  inherit
    (lib)
    concatStringsSep
    escapeShellArg
    getExe
    getName
    getOutput
    mapAttrsToList
    optional
    optionalAttrs
    optionalString
    ;

  linuxMaplestory = fetchFromGitHub {
    owner = "oldschoola";
    repo = "linux_maplestory";
    rev = "181cd74cf51db5fd2563ec81359a94db9a2ada32";
    hash = "sha256-+he7njwlTvw7PeLXw8GVQYaqphJmmjG4jF8ODAtqcr8=";
  };

  protonCompatPath =
    if protonVersion == null
    then ""
    else let
      base = getOutput "steamcompattool" protonVersion;
    in
      runCommand "${getName protonVersion}-steamcompattool" {
        preferLocalBuild = true;
        allowSubstitutes = false;
      } ''
        if [ -e ${escapeShellArg "${base}/proton"} ] || [ -f ${escapeShellArg "${base}/compatibilitytool.vdf"} ]; then
          ln -s ${escapeShellArg base} "$out"
        elif [ -e ${escapeShellArg "${base}/bin/proton"} ] || [ -f ${escapeShellArg "${base}/bin/compatibilitytool.vdf"} ]; then
          ln -s ${escapeShellArg "${base}/bin"} "$out"
        else
          echo "nix-nexon-launcher: no Proton compat tool found in ${base} or ${base}/bin" >&2
          exit 1
        fi
      '';

  extraCompatPaths = protonCompatPath;

  installerUrl = "https://download.nxfs.nexon.com/download-launcher?file=NexonLauncherSetup.exe";

  mergedEnvironment =
    {
      GAMEID = "umu-216150";
      STORE = "none";
      WINE_SIMULATE_WRITECOPY = "1";
      PROTON_USE_NTSYNC = "1";
      LAUNCHER_ARGS = launcherArgs;
      VIRTUAL_DESKTOP =
        if virtualDesktop != null
        then virtualDesktop
        else "";
    }
    // environment
    // {
      PROTON_USE_WINED3D =
        if useWineD3D
        then "1"
        else "0";
      PROTON_ENABLE_WAYLAND =
        if enableProtonWayland
        then "1"
        else "0";
      PROTON_USE_WAYLAND =
        if enableProtonWayland
        then "1"
        else "0";
    }
    // optionalAttrs (preLaunchArgs != "") {PRE_LAUNCH_ARGS = preLaunchArgs;};

  packagedConfig = writeText "nix-nexon-launcher.env" (
    concatStringsSep "\n" (mapAttrsToList (k: v: "${k}=${escapeShellArg v}") mergedEnvironment) + "\n"
  );

  resolvedConfig =
    if configFile != null
    then configFile
    else packagedConfig;

  maplestoryRegPatch = writeText "maplestory-nexon-fixes.reg" ''
    Windows Registry Editor Version 5.00

    ; Alt-tab input fix - prevent Wine from stealing focus on alt-tab
    [HKEY_CURRENT_USER\Software\Wine\X11 Driver]
    "UseTakeFocus"="N"
    "Grab"="N"
    "GrabFullscreen"="N"
    "UseLinuxInputEvents"="Y"

    ; DirectInput raw input events for keyboard/mouse (MapleStory skill keys)
    [HKEY_CURRENT_USER\Software\Wine\DirectInput]
    "UseLinuxInputEvents"="Y"
    "KeyboardUseNonExclusive"="Y"
    "MouseUseNonExclusive"="Y"

    ; Report Windows 10 to MapleStory and Nexon Launcher components
    [HKEY_CURRENT_USER\Software\Wine\AppDefaults\MapleStory.exe]
    "Version"="win10"

    [HKEY_CURRENT_USER\Software\Wine\AppDefaults\nexon_launcher.exe]
    "Version"="win10"

    [HKEY_CURRENT_USER\Software\Wine\AppDefaults\nexon_runtime.exe]
    "Version"="win10"

    [HKEY_CURRENT_USER\Software\Wine\AppDefaults\nexon_client.exe]
    "Version"="win10"

    [HKEY_CURRENT_USER\Software\Wine\AppDefaults\nxsteam.exe]
    "Version"="win10"

    [HKEY_CURRENT_USER\Software\Wine\AppDefaults\SteamConnectorHelper.exe]
    "Version"="win10"

    ; Direct3D & VC++ runtime DLL overrides
    [HKEY_CURRENT_USER\Software\Wine\Direct3D]
    "cb_access_map_w"=dword:00000001
    "CSMT"="disabled"

    [HKEY_CURRENT_USER\Software\Wine\DllOverrides]
    "concrt140"="native,builtin"
    "msvcp140"="native,builtin"
    "msvcp140_1"="native,builtin"
    "msvcp140_2"="native,builtin"
    "msvcp140_atomic_wait"="native,builtin"
    "msvcp140_codecvt_ids"="native,builtin"
    "ucrtbase"="native,builtin"
    "vcomp140"="native,builtin"
    "vcruntime140"="native,builtin"
    "vcruntime140_1"="native,builtin"
    "vcruntime140_threads"="native,builtin"

    ; Hide floating Wine systray window
    [HKEY_CURRENT_USER\Software\Wine\Explorer]
    "ShowSystray"=dword:00000000
  '';

  iconSvg = writeText "nexon-launcher.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
      <rect width="64" height="64" rx="14" fill="#0d1117"/>
      <polygon points="12,18 32,10 38,28 18,36" fill="#00a8ff"/>
      <polygon points="18,36 38,28 52,46 32,54" fill="#7ed957"/>
      <polygon points="32,10 52,18 38,28" fill="#1e90ff"/>
    </svg>
  '';

  script = writeShellApplication {
    name = pname;
    runtimeInputs =
      [
        coreutils
        curl
        wget
        procps
        gnugrep
        gnused
        findutils
        winetricks
        umu-launcher
      ]
      ++ optional useGameMode gamemode;

    text = ''
      set -euo pipefail

      LOCATION="''${LOCATION:-${location}}"
      LOCATION="''${LOCATION/#\~/$HOME}"
      STATE_DIR="$LOCATION"
      WINEPREFIX_DIR="$STATE_DIR/prefix"
      INSTALLER_DIR="$STATE_DIR/installer"
      LOG_DIR="$STATE_DIR/logs"
      CONFIG_FILE="''${NEXON_LAUNCHER_CONFIG:-${resolvedConfig}}"
      PACKAGED_PROTON="${protonCompatPath}"
      PACKAGED_COMPAT_PATHS="${extraCompatPaths}"
      INSTALLER_URL="''${NEXON_LAUNCHER_INSTALLER_URL:-${installerUrl}}"
      INSTALLER_EXE="$INSTALLER_DIR/NexonLauncherSetup.exe"
      UMU_RUN=${escapeShellArg (getExe umu-launcher)}
      MAPLESTORY_BUNDLE=${escapeShellArg "${linuxMaplestory}"}
      BASE_REG_PATCH=${escapeShellArg "${maplestoryRegPatch}"}
      NEXON_EXE=""

      export WINEPREFIX="$WINEPREFIX_DIR"
      export GAMEID="''${GAMEID:-umu-216150}"
      export STORE="''${STORE:-none}"

      if [ -r "$CONFIG_FILE" ]; then
        set -a
        # shellcheck disable=SC1090
        source "$CONFIG_FILE"
        set +a
      fi

      info() { printf '\033[1;34mnix-nexon-launcher:\033[0m %s\n' "$*" >&2; }
      err() { printf '\033[1;31mnix-nexon-launcher:\033[0m %s\n' "$*" >&2; }

      find_proton_dir() {
        local candidate="$1"
        if [ -e "$candidate/proton" ]; then
          printf '%s' "$candidate"
          return 0
        fi
        if [ -e "$candidate/bin/proton" ]; then
          printf '%s' "$candidate/bin"
          return 0
        fi
        return 1
      }

      resolve_proton() {
        local resolved=""
        if [ -n "''${PROTONPATH:-}" ]; then
          if ! resolved="$(find_proton_dir "$PROTONPATH")"; then
            err "PROTONPATH does not look like a Proton build: $PROTONPATH"
            err "Need a Steam compat tool directory containing a proton script (or bin/proton)."
            return 1
          fi
        elif [ -n "$PACKAGED_PROTON" ] && [ -d "$PACKAGED_PROTON" ]; then
          if ! resolved="$(find_proton_dir "$PACKAGED_PROTON")"; then
            err "Packaged Proton does not look like a Proton build: $PACKAGED_PROTON"
            err "Need a Steam compat tool directory containing a proton script (or bin/proton)."
            return 1
          fi
        else
          err "No Proton found."
          err "Set programs.nexon-launcher.protonPackage (e.g. unstable-pkgs.proton-ge-bin)"
          err "or export PROTONPATH to a Steam compat tool directory."
          return 1
        fi
        export PROTONPATH="$resolved"

        if [ -n "$PACKAGED_COMPAT_PATHS" ]; then
          if [ -n "''${STEAM_EXTRA_COMPAT_TOOLS_PATHS:-}" ]; then
            export STEAM_EXTRA_COMPAT_TOOLS_PATHS="$PACKAGED_COMPAT_PATHS:''${STEAM_EXTRA_COMPAT_TOOLS_PATHS}"
          else
            export STEAM_EXTRA_COMPAT_TOOLS_PATHS="$PACKAGED_COMPAT_PATHS"
          fi
        fi
      }

      resolve_wine_bin() {
        local c
        for c in \
          "$PROTONPATH/files/bin/wine" \
          "$PROTONPATH/files/bin/wine64" \
          "$PROTONPATH/dist/bin/wine" \
          "$PROTONPATH/dist/bin/wine64"
        do
          if [ -x "$c" ]; then
            printf '%s' "$c"
            return 0
          fi
        done
        return 1
      }

      wait_wineserver() {
        local pfx="$1"
        local ws
        for ws in "$PROTONPATH/files/bin/wineserver" "$PROTONPATH/dist/bin/wineserver"; do
          if [ -x "$ws" ]; then
            WINEPREFIX="$pfx" "$ws" -w 2>/dev/null || true
            return 0
          fi
        done
      }

      run_umu() {
        local -a cmd=()
        ${optionalString useGameMode "cmd+=(${escapeShellArg "${gamemode}/bin/gamemoderun"})"}
        if [ -n "''${PRE_LAUNCH_ARGS:-}" ]; then
          local -a pre_args=()
          # shellcheck disable=SC2206
          read -r -a pre_args <<<"''${PRE_LAUNCH_ARGS}"
          cmd+=("''${pre_args[@]}")
        fi
        cmd+=("$UMU_RUN")
        exec "''${cmd[@]}" "$@"
      }

      nexon_exe() {
        local pfx="''${1:-$WINEPREFIX_DIR}"
        local c
        local candidates=(
          "$pfx/drive_c/Nexon/Launcher/nexon_launcher.exe"
          "$pfx/drive_c/Program Files (x86)/Nexon/Nexon Launcher/nexon_launcher.exe"
          "$pfx/drive_c/Program Files/Nexon/Nexon Launcher/nexon_launcher.exe"
          "$pfx/drive_c/users/steamuser/AppData/Local/Nexon/Nexon Launcher/nexon_launcher.exe"
        )
        for c in "''${candidates[@]}"; do
          if [ -s "$c" ]; then
            printf '%s' "$c"
            return 0
          fi
        done
        return 1
      }

      nexon_win_dir() {
        local pfx="''${1:-$WINEPREFIX_DIR}"
        local exe
        if exe="$(nexon_exe "$pfx" 2>/dev/null)"; then
          local rel="''${exe#"$pfx/drive_c/"}"
          local dir
          dir="$(dirname "$rel")"
          printf 'C:\\%s' "''${dir//\//\\}"
        else
          printf 'C:\\Program Files (x86)\\Nexon\\Nexon Launcher'
        fi
      }

      download_installer() {
        local tmp
        mkdir -p "$INSTALLER_DIR"
        if [ -s "$INSTALLER_EXE" ] && [ "$(head -c 2 "$INSTALLER_EXE")" = "MZ" ]; then
          return 0
        fi
        tmp="$(mktemp "$INSTALLER_EXE.XXXXXX.tmp")"
        info "Downloading Nexon Launcher installer"
        info "  from: $INSTALLER_URL"
        info "  to:   $INSTALLER_EXE"
        if curl -fL --progress-bar -o "$tmp" "$INSTALLER_URL"; then
          :
        elif wget --show-progress -O "$tmp" "$INSTALLER_URL"; then
          :
        else
          rm -f "$tmp"
          err "Failed to download Nexon Launcher installer (need network + curl/wget)"
          return 1
        fi
        if [ ! -s "$tmp" ] || [ "$(head -c 2 "$tmp")" != "MZ" ]; then
          rm -f "$tmp"
          err "Download does not look like a Windows executable"
          return 1
        fi
        mv -f "$tmp" "$INSTALLER_EXE"
        chmod u+rw "$INSTALLER_EXE"
        info "Installer ready ($(du -h "$INSTALLER_EXE" | cut -f1))"
      }

      ensure_prefix() {
        mkdir -p "$WINEPREFIX_DIR" "$LOG_DIR"
        if [ -r "$WINEPREFIX_DIR/system.reg" ] && [ -d "$WINEPREFIX_DIR/drive_c/windows/system32" ]; then
          return 0
        fi
        info "Creating Proton prefix at $WINEPREFIX_DIR"
        "$UMU_RUN" wineboot -u || {
          err "umu-run failed to create the prefix"
          return 1
        }
      }

      import_reg_file() {
        local pfx="$1"
        local reg_file="$2"
        local wine_bin=""
        if wine_bin="$(resolve_wine_bin 2>/dev/null)"; then
          WINEPREFIX="$pfx" "$wine_bin" regedit /S "$reg_file" 2>/dev/null || true
          wait_wineserver "$pfx"
        else
          WINEPREFIX="$pfx" "$UMU_RUN" regedit /S "$reg_file" 2>/dev/null || true
        fi
      }

      apply_maplestory_fixes() {
        local pfx="''${1:-$WINEPREFIX_DIR}"
        if [ ! -d "$pfx/drive_c" ]; then
          err "Prefix drive_c not found at $pfx/drive_c"
          return 1
        fi

        info "Applying MapleStory & Nexon Launcher runtime fixes to $pfx"

        # 1. App-name mappings & English locale
        printf '%s\n' \
          'MapleStory.exe=MapleStory' \
          'nexon_client.exe=Nexon Launcher' \
          'nexon_updater.exe=Nexon Updater' \
          > "$pfx/drive_c/.mappings.ini"

        mkdir -p "$pfx/drive_c/users/steamuser/AppData/Roaming/NexonLauncher"
        if [ ! -s "$pfx/drive_c/users/steamuser/AppData/Roaming/NexonLauncher/apps-settings.db" ]; then
          printf '%s' '{"locale":"en_US"}' > "$pfx/drive_c/users/steamuser/AppData/Roaming/NexonLauncher/apps-settings.db"
        fi

        # 2. VC++ 2022 runtime DLLs (including vcruntime140_threads.dll omitted by MapleStory installer)
        mkdir -p "$pfx/drive_c/windows/system32" "$pfx/drive_c/windows/syswow64"
        local dll
        for dll in "$MAPLESTORY_BUNDLE"/files/vc_runtime/system32/*.dll; do
          cp -f "$dll" "$pfx/drive_c/windows/system32/$(basename "$dll")"
          chmod u+rw "$pfx/drive_c/windows/system32/$(basename "$dll")"
        done
        for dll in "$MAPLESTORY_BUNDLE"/files/vc_runtime/syswow64/*.dll; do
          cp -f "$dll" "$pfx/drive_c/windows/syswow64/$(basename "$dll")"
          chmod u+rw "$pfx/drive_c/windows/syswow64/$(basename "$dll")"
        done

        # 3. Registry settings (Win10, DirectInput UseLinuxInputEvents, UseTakeFocus=N, nxl: protocol, Virtual Desktop)
        local win_dir win_dir_escaped tmp_reg
        win_dir="$(nexon_win_dir "$pfx")"
        win_dir_escaped="''${win_dir//\\/\\\\}"
        tmp_reg="$pfx/drive_c/nix_nexon_maplestory.reg"
        cp -f "$BASE_REG_PATCH" "$tmp_reg"
        chmod u+rw "$tmp_reg"

        cat >> "$tmp_reg" <<EOF

      [HKEY_CURRENT_USER\Software\Nexon Launcher]
      "Install Directory"="$win_dir_escaped"
      "Region"="1"

      [HKEY_LOCAL_MACHINE\Software\Classes\Applications\nexon_launcher.exe\shell\open]
      "FriendlyAppName"="Nexon Launcher"

      [HKEY_LOCAL_MACHINE\Software\Classes\nxl]
      @="URL:nxl protocol"
      "URL Protocol"=""

      [HKEY_LOCAL_MACHINE\Software\Classes\nxl\DefaultIcon]
      @="$win_dir_escaped\\\\nexon_launcher.exe"

      [HKEY_LOCAL_MACHINE\Software\Classes\nxl\shell]
      @=""

      [HKEY_LOCAL_MACHINE\Software\Classes\nxl\shell\open]
      @=""
      "Friendly App Name"="Nexon Launcher"

      [HKEY_LOCAL_MACHINE\Software\Classes\nxl\shell\open\command]
      @="\\"$win_dir_escaped\\\\nexon_launcher.exe\\" \\"%1\\""
      EOF

        if [ -n "''${VIRTUAL_DESKTOP:-}" ]; then
          cat >> "$tmp_reg" <<EOF

      [HKEY_CURRENT_USER\Software\Wine\Explorer]
      "Desktop"="Default"

      [HKEY_CURRENT_USER\Software\Wine\Explorer\Desktops]
      "Default"="''${VIRTUAL_DESKTOP}"
      EOF
        else
          cat >> "$tmp_reg" <<EOF

      [HKEY_CURRENT_USER\Software\Wine\Explorer]
      "Desktop"=-

      [-HKEY_CURRENT_USER\Software\Wine\Explorer\Desktops]
      EOF
        fi

        import_reg_file "$pfx" "C:\\nix_nexon_maplestory.reg"
        rm -f "$tmp_reg"
      }

      ensure_nexon_launcher() {
        if NEXON_EXE="$(nexon_exe)"; then
          return 0
        fi
        download_installer
        ensure_prefix
        apply_maplestory_fixes "$WINEPREFIX_DIR"
        info "Running Nexon Launcher installer — finish setup, then close it if needed"
        "$UMU_RUN" "$INSTALLER_EXE" || true
        if NEXON_EXE="$(nexon_exe)"; then
          apply_maplestory_fixes "$WINEPREFIX_DIR"
          return 0
        fi
        err "nexon_launcher.exe not found under $WINEPREFIX_DIR"
        err "Finish the installer, then run ${pname} again."
        return 1
      }

      kill_nexon() {
        pkill -f -i 'nexon_launcher|nexon_runtime|nexon_client|nexon_updater|MapleStory\.exe|nxsteam|BlackCipher|DwarfAxe|NGClient' 2>/dev/null || true
        pkill -f wineserver 2>/dev/null || true
      }

      check_input_group() {
        if ! id -nG 2>/dev/null | grep -qw input; then
          info "Warning: current session is not in the 'input' group."
          info "MapleStory uses Wine DirectInput (UseLinuxInputEvents) for in-game skill keys."
          info "Log out and back in after rebuilding NixOS so your 'input' group membership takes effect."
        fi
      }

      prepare() {
        mkdir -p "$STATE_DIR" "$INSTALLER_DIR" "$LOG_DIR"
        resolve_proton
        export WINEPREFIX="$WINEPREFIX_DIR"
      }

      usage() {
        cat <<EOF
      Usage: ${pname} [command]

        (no args)                  Launch Nexon Launcher
        --help                     Show this help
        --info                     Show config / paths
        --kill                     Force quit Nexon Launcher / MapleStory / BlackCipher / wineserver
        --reapply-fixes            Re-apply MapleStory VC++ runtime & registry fixes to the prefix
        --patch-steam [STEAM_DIR]  Apply MapleStory VC++ runtime & registry fixes to Steam's 216150 prefix
        --virtual-desktop [WxH]    Launch with Wine virtual desktop (default 1920x1080 if WxH omitted)
        --winecfg                  Open Wine configuration in the prefix
        --regedit                  Open Registry Editor in the prefix
        --winetricks …             Run winetricks in the prefix
        --umu <args>               Pass arguments to umu-run

      State: $STATE_DIR
      Config: $CONFIG_FILE
      EOF
      }

      case "''${1:-}" in
        --help|-h) usage; exit 0 ;;
        --info)
          prepare
          cat <<EOF
      State:           $STATE_DIR
      Wineprefix:      $WINEPREFIX_DIR
      Proton:          ''${PROTONPATH:-}
      umu-run:         $UMU_RUN
      config:          $CONFIG_FILE
      installer:       $INSTALLER_URL
      virtual-desktop: ''${VIRTUAL_DESKTOP:-(disabled)}
      launcher:        $(nexon_exe 2>/dev/null || echo "(not installed)")
      EOF
          exit 0
          ;;
        --kill)
          kill_nexon
          info "Stopped Nexon Launcher / MapleStory / wineserver."
          exit 0
          ;;
        --reapply-fixes)
          prepare
          ensure_prefix
          apply_maplestory_fixes "$WINEPREFIX_DIR"
          info "MapleStory & Nexon Launcher fixes applied to $WINEPREFIX_DIR."
          exit 0
          ;;
        --patch-steam)
          prepare
          steam_root="''${2:-}"
          if [ -z "$steam_root" ]; then
            for candidate in "$HOME/.local/share/Steam" "$HOME/.steam/steam"; do
              if [ -d "$candidate/steamapps/compatdata/216150/pfx/drive_c" ]; then
                steam_root="$candidate"
                break
              fi
            done
          fi
          if [ -z "$steam_root" ] || [ ! -d "$steam_root/steamapps/compatdata/216150/pfx/drive_c" ]; then
            err "Could not find Steam MapleStory prefix (compatdata/216150/pfx/drive_c)."
            err "Launch MapleStory once in Steam first or pass --patch-steam /path/to/Steam."
            exit 1
          fi
          apply_maplestory_fixes "$steam_root/steamapps/compatdata/216150/pfx"
          info "Patched Steam MapleStory prefix at $steam_root/steamapps/compatdata/216150/pfx"
          exit 0
          ;;
        --virtual-desktop)
          shift
          if [ -n "''${1:-}" ] && [[ "''${1:-}" =~ ^[0-9]+x[0-9]+$ ]]; then
            export VIRTUAL_DESKTOP="$1"
            shift
          else
            export VIRTUAL_DESKTOP="''${VIRTUAL_DESKTOP:-1920x1080}"
          fi
          prepare
          check_input_group
          ensure_nexon_launcher
          apply_maplestory_fixes "$WINEPREFIX_DIR"
          info "Launching $NEXON_EXE (virtual desktop: $VIRTUAL_DESKTOP)"
          run_umu "$NEXON_EXE" "$@"
          ;;
        --winecfg)
          prepare
          ensure_prefix
          exec "$UMU_RUN" winecfg
          ;;
        --regedit)
          prepare
          ensure_prefix
          exec "$UMU_RUN" regedit
          ;;
        --winetricks)
          prepare
          ensure_prefix
          shift
          exec "$UMU_RUN" winetricks "$@"
          ;;
        --umu)
          prepare
          ensure_prefix
          shift
          exec "$UMU_RUN" "$@"
          ;;
        "")
          prepare
          check_input_group
          ensure_nexon_launcher
          apply_maplestory_fixes "$WINEPREFIX_DIR"
          info "Launching $NEXON_EXE"
          launcher_args=()
          if [ -n "''${LAUNCHER_ARGS:-}" ]; then
            # shellcheck disable=SC2206
            read -r -a launcher_args <<<"''${LAUNCHER_ARGS}"
          fi
          run_umu "$NEXON_EXE" "''${launcher_args[@]}"
          ;;
        *)
          err "Unknown command: $1"
          usage
          exit 1
          ;;
      esac
    '';
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${script}/bin/${pname}";
    icon = "nexon-launcher";
    comment = "Nexon Launcher for MapleStory (umu-launcher + Proton)";
    desktopName = "Nexon Launcher";
    categories = ["Game"];
    mimeTypes = ["x-scheme-handler/nxl"];
  };

  iconShare = runCommand "nexon-launcher-icon" {} ''
    install -Dm644 ${iconSvg} \
      "$out/share/icons/hicolor/scalable/apps/nexon-launcher.svg"
  '';
in
  symlinkJoin {
    name = pname;
    paths = [
      script
      desktopItem
      iconShare
    ];
    passthru = {
      inherit protonVersion protonCompatPath extraCompatPaths linuxMaplestory;
      envConfig = resolvedConfig;
      inherit installerUrl;
    };
    meta = {
      description = "Declarative Nexon Launcher for MapleStory using umu-launcher and GE-Proton";
      homepage = "https://www.nexon.com";
      license = lib.licenses.unfree;
      platforms = ["x86_64-linux"];
      mainProgram = pname;
    };
  }
