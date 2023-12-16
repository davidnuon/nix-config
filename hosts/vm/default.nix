{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../mixins/base
  ];

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
