{specialArgs, ...}:
specialArgs.nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  system = "x86_64-linux";
  modules = [
    ../../mixins
    {
      mixins.base.enable = true;
    }
    {
      users.users = {
        admin = {
          isSystemUser = true;
          initialPassword = "test";
          group = "admin";
        };
      };

      users.groups.admin = {};

      virtualisation.vmVariant = {
        virtualisation = {
          memorySize = 6000;
          cores = 3;
        };
      };
    }
  ];
}
