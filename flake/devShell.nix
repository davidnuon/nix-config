{
  inputs,
  systems,
  ...
}: let
  inherit (inputs) disko nixpkgs plasma-manager;
  mkShell = system: let
    disko-pkg = disko.packages.${system}.default;
    pkgs = import nixpkgs {
      system = "${system}";
    };
    packages = with pkgs; [
      nix
      vim
      home-manager
      git
      gnumake
      alejandra
      nixVersions.latest
      nixos-rebuild
      nixos-install-tools
      nix-output-monitor
      disko-pkg
      sops
      ssh-to-age
      efibootmgr
    ];
  in {
    name = "${system}";
    value = {
      default = pkgs.mkShell {
        nativeBuildInputs = packages;
      };
    };
  };
in (builtins.listToAttrs (builtins.map mkShell systems))
