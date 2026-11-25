inputs @ {
  self,
  nixpkgs,
  ...
}: let
  inherit (self.library) mkConfigurationsFrom;
  sharedHostModules = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        useUserPackages = true;
        extraSpecialArgs = {inherit inputs;};
        sharedModules = [
          inputs.plasma-manager.homeModules.plasma-manager
        ];
      };
    }
    ../users/davidnuon
    ../mixins
  ];
in
  nixpkgs.lib.mapAttrs (
    _: cfg:
      cfg.extendModules {
        specialArgs = self.library.extendedSpecialArgs;
        modules = sharedHostModules;
      }
  ) (mkConfigurationsFrom ../hosts)
