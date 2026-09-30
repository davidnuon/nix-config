# Remote Builder Mixin

This mixin configures Nix distributed builds across machines on the local network. It allows resource-constrained or mobile machines (such as `dn-blackleg`) to offload builds to dedicated, always-on desktop hardware (such as `dn-microwave`).

## Architecture

The module automatically determines its role based on `networking.hostName`:

1. **Build Server (`dn-microwave`)**:
   - Designates `davidnuon` as a trusted Nix user in `nix.settings.trusted-users` so the remote daemon accepts derivation closures and store paths.
   - Authorizes the client SSH public keys in `users.users.<user>.openssh.authorizedKeys.keys`.

2. **Build Client (`dn-blackleg` or any other host)**:
   - Enables `nix.distributedBuilds`.
   - Configures `dn-microwave` (`10.0.0.61`) in `nix.buildMachines` using the high-performance `ssh-ng` protocol.
   - Sets `builders-use-substitutes = true` so the builder downloads public dependencies from cache.nixos.org directly rather than transferring them across the local link.
   - Registers the builder host public key in `programs.ssh.knownHosts` system-wide so non-interactive builds via the Nix daemon do not stall or fail on host key verification.

## One-Time Setup (Client)

When running `sudo nixos-rebuild switch` (or `make nixos.switch`), builds are executed by the local Nix daemon running as user `root`. OpenSSH requires private keys to be owned by the user initiating the connection (`root`).

On the client machine (`dn-blackleg`), copy the private key to `/root/.ssh`:

```bash
sudo mkdir -p /root/.ssh
sudo cp ~/.ssh/id_ed25519 /root/.ssh/id_ed25519
sudo chmod 600 /root/.ssh/id_ed25519
```

## Importing the Mixin

Add the mixin to a host definition in `hosts/<target>/default.nix`:

```nix
modules = [
  # ...
  ../../mixins/remote-builder
];
```

## Configuration Options

Options are exposed under `services.remote-builder`:

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | boolean | `true` | Enables the remote builder mixin. |
| `isServer` | boolean | `config.networking.hostName == "dn-microwave"` | Whether the host functions as the build server or build client. |
| `builderHost` | string | `"10.0.0.61"` | Static IP or hostname of the remote builder machine. |
| `builderPublicKey` | string | `ssh-ed25519 AAAAC3NzaC1lZDI1...` | SSH host public key for known hosts verification. |
| `sshUser` | string | `"davidnuon"` | User account used to log into the remote builder. |
| `sshKey` | string | `"/root/.ssh/id_ed25519"` | Path to the private SSH key used by the client Nix daemon. |
| `system` | string | `"aarch64-linux"` | Architecture supported by the remote builder. |
| `maxJobs` | integer | `8` | Maximum concurrent build jobs to allocate to the builder. |
| `speedFactor` | integer | `2` | Relative speed weighting compared to local cores. |
| `clientPublicKeys` | list of strings | `[ ... ]` | List of authorized client public keys accepted by the server. |

### Overriding Options Example

To use a different builder host or key on a specific machine:

```nix
services.remote-builder = {
  builderHost = "10.0.0.70";
  maxJobs = 16;
};
```

## Verification

### 1. Check Store Trust from Client

Run the following command on `dn-blackleg` to test connectivity and trusted status:

```bash
nix store ping --store ssh-ng://davidnuon@10.0.0.61
```

Expected output:
```text
Store URL: ssh-ng://davidnuon@10.0.0.61
Version: 2.34.8
Trusted: 1
```

`Trusted: 1` confirms that the remote daemon accepts build requests.

### 2. Run a Test Remote Build

Force a derivation to build exclusively on the remote builder by setting `--max-jobs 0`:

```bash
nix build --expr 'derivation { name = "remote-test"; builder = "/bin/sh"; args = ["-c" "echo built-on-$(hostname) > $out"]; system = "aarch64-linux"; }' --max-jobs 0
cat result
```

Output should read:
```text
built-on-dn-microwave
```
