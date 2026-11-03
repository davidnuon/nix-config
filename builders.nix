# builders.nix
# Central registry of build coordinator, binary cache, and remote build machines
let
  hosts = import ./hosts.nix;
in {
  # Central Harmonia binary cache and Buildbot coordinator
  cacheHost = hosts.dn-mememobile;
  cachePort = 5000;
  cachePublicKey = "dn-mememobile-1:WltXjnqq31qus5i6nkhMsk5OCcRbwFM1VwJ7kLmFSQg=";

  # SSH public keys of coordinator hosts allowed to dispatch remote builds
  coordinatorAuthorizedKeys = [
    # dn-mememobile (/etc/ssh/ssh_host_ed25519_key.pub)
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6x0tU7X4mePF5TgMycCL8epgzbMtiA7/Lk6xUt4pne root@dn-mememobile"
  ];

  # Remote builder definitions by role/group
  machines = {
    arm = {
      hostName = hosts.dn-microwave;
      sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+xBCK0DNbLFkvacsVk6MzX/8AFC7XqFHIBoY18YwEQ";
      systems = ["aarch64-linux"];
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
    };
  };
}
