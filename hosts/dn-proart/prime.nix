{
  config,
  lib,
  pkgs,
  ...
}: {
  hardware.nvidia = {
    prime = {
      # Enable PRIME render offload
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      # Bus IDs for ASUS ProArt (AMD Ryzen AI 9 APU + NVIDIA GeForce RTX 4060 Mobile)
      # NVIDIA: 0000:64:00.0 -> 0x64 = 100 decimal -> PCI:100:0:0
      # AMD:    0000:65:00.0 -> 0x65 = 101 decimal -> PCI:101:0:0
      nvidiaBusId = "PCI:100:0:0";
      amdgpuBusId = "PCI:101:0:0";
    };

    # Fine-grained power management turns off the dGPU when not in use (RTD3).
    # Requires Turing or newer GPU (RTX 4060 is Ada Lovelace) and PRIME offload.
    powerManagement.finegrained = true;
  };

  # Enable switcheroo-control for D-Bus dual-GPU switching.
  # Provides integration for desktop environments (e.g. GNOME "Launch using Dedicated Graphics Card").
  services.switcherooControl.enable = true;

  # Specialisation: Run the entire desktop session on NVIDIA
  specialisation = {
    nvidia.configuration = {
      system.nixos.tags = ["nvidia-session"];

      # Direct GNOME Mutter (Wayland) to use the NVIDIA GPU as primary rendering device
      services.udev.extraRules = ''
        ENV{ID_PATH}=="pci-0000:64:00.0", TAG+="mutter-device-preferred-primary"
      '';

      # Set session environment variables so all desktop apps and Xwayland run on NVIDIA by default
      environment.sessionVariables = {
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __VK_LAYER_NV_optimus = "NVIDIA_only";
      };

      # Keep the GPU awake while driving the entire desktop session
      hardware.nvidia.powerManagement.finegrained = lib.mkForce false;
    };
  };

  environment.systemPackages = [
    # Provide 'prime-run' convenience wrapper alongside 'nvidia-offload'
    (pkgs.writeShellScriptBin "prime-run" ''
      exec nvidia-offload "$@"
    '')

    # Provide 'gpu-switch' CLI tool to switch between AMD and NVIDIA sessions
    (pkgs.writeShellScriptBin "gpu-switch" ''
      set -e

      show_help() {
        echo "Usage: gpu-switch [amd|nvidia|status]"
        echo ""
        echo "Commands:"
        echo "  status   Show the current session GPU mode and power state"
        echo "  nvidia   Switch entire session to NVIDIA (Dedicated / High Performance)"
        echo "  amd      Switch entire session to AMD (Integrated / Battery Saving)"
      }

      case "$1" in
        status)
          echo "=== GPU Session Status ==="
          if [ -d /run/current-system/specialisation/nvidia ]; then
            echo "Active Mode: AMD (Default / Hybrid Offload)"
          else
            echo "Active Mode: NVIDIA (Dedicated Session)"
          fi
          echo -n "NVIDIA GPU Power State: "
          cat /sys/bus/pci/devices/0000:64:00.0/power/runtime_status 2>/dev/null || echo "Unknown"
          ;;
        nvidia)
          SPEC="/run/current-system/specialisation/nvidia"
          if [ ! -d "$SPEC" ]; then
            SPEC="/nix/var/nix/profiles/system/specialisation/nvidia"
          fi
          if [ ! -d "$SPEC" ]; then
            echo "Already in NVIDIA mode or specialisation not found."
            exit 0
          fi
          echo "Switching system configuration to NVIDIA session..."
          sudo "$SPEC/bin/switch-to-configuration" switch
          echo ""
          echo "Switched to NVIDIA! Please log out and back in (or reboot) for your desktop session to apply."
          ;;
        amd)
          BASE="/run/booted-system"
          if [ ! -d "$BASE" ] || [ -d "$BASE/specialisation" ]; then
            BASE="/nix/var/nix/profiles/system"
          fi
          echo "Switching system configuration to AMD session..."
          sudo "$BASE/bin/switch-to-configuration" switch
          echo ""
          echo "Switched to AMD! Please log out and back in (or reboot) for your desktop session to apply."
          ;;
        *)
          show_help
          exit 1
          ;;
      esac
    '')
  ];
}
