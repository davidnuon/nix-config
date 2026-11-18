{
  description = "davidnuon's NixOS configuration";
  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    aerothemeplasma-nix = {
      url = "github:davidnuon/aerothemeplasma-nix/26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    affinity-nix.url = "github:davidnuon/affinity-nix";

    artcraft-nix = {
      url = "github:ipeglin/artcraft-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-photo-gimp = {
      url = "github:Libadoxon/nix-photo-gimp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-battle-net = {
      url = "github:gmaxpwnage/nix-battle-net";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    forge = {
      url = "github:Card-Forge/forge";
      flake = false;
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    buildbot-nix = {
      url = "github:nix-community/buildbot-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    graphite-editor = {
      url = "github:GraphiteEditor/Graphite";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs: import ./flake inputs;
}
