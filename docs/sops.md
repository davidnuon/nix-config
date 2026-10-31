# Managing Secrets with SOPS (`sops-nix`)

This repository uses **[sops-nix](https://github.com/Mic92/sops-nix)** for declarative, per-host secrets management. Secrets are encrypted using **Age** keys and stored directly in Git. Because only the encrypted ciphertext is committed to the repository, this setup is completely safe for public GitHub repositories.

---

## Architecture Overview

```text
nix-config/
├── .sops.yaml                      # Root config: Maps host Age keys to files
├── flake.nix                       # Imports sops-nix input
├── devShell.nix                    # Provides `sops` and `ssh-to-age` CLI tools
├── docs/
│   └── sops.md                     # This documentation
└── hosts/
    ├── dn-mememobile/
    │   ├── default.nix             # Imports sops module & secrets.nix
    │   ├── secrets.nix             # Declares secrets for this host
    │   └── secrets.yaml            # Encrypted secrets file (committed to Git)
    └── <other-hosts>/
```

### How It Works

1. **Host Identity**: Each NixOS machine has an SSH host key (`/etc/ssh/ssh_host_ed25519_key`). This key is converted into an **Age public key** using `ssh-to-age`.
2. **Targeted Encryption**: In `.sops.yaml`, each host's secrets file (`hosts/<host>/secrets.yaml`) is configured to be encrypted with that specific host's Age key (and optionally your personal admin key).
3. **Decryption at Boot**: When running `nixos-rebuild switch` (or on boot), `sops-nix` uses the host's private SSH key to decrypt secrets into a RAM-backed tmpfs at `/run/secrets/<secret-name>`.
4. **Security**: The plaintext never touches disk or the world-readable `/nix/store`.

---

## Tooling & Dev Environment

The required tools (`sops` and `ssh-to-age`) are included in `devShell.nix`.

To enter the environment:
```bash
nix develop
```

Or run ad-hoc:
```bash
nix-shell -p sops ssh-to-age
```

---

## Day-to-Day Operations

### 1. Editing Secrets for an Existing Host

To view or edit secrets for a machine:

```bash
sops hosts/dn-mememobile/secrets.yaml
```

* This decrypts the file in your `$EDITOR` (e.g. `vim`, `nano`).
* When you save and quit, SOPS re-encrypts the file automatically before writing it back to disk.
* Commit the modified `secrets.yaml` to Git:
  ```bash
  git add hosts/dn-mememobile/secrets.yaml
  git commit -m "Update secrets for dn-mememobile"
  ```

---

### 2. Adding Secrets to a New Host

When adding secrets to another host (e.g., `dn-obsidian`):

#### Step 1: Obtain the Host's Age Key
On the target host, run:
```bash
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
# Example output: age1ftzlyrkrr0xaa7yfgam3lrvr3x24czp6k3gf3x3xvv03ez6uvdmsymuu5d
```

*(Alternatively, from another machine that can reach it over the network):*
```bash
ssh-keyscan dn-obsidian 2>/dev/null | ssh-to-age
```

#### Step 2: Add the Host to `.sops.yaml`
Edit `.sops.yaml` at the root of the repo:

```yaml
keys:
  # --- Host Keys ---
  - &dn-mememobile age1ftzlyrkrr0xaa7yfgam3lrvr3x24czp6k3gf3x3xvv03ez6uvdmsymuu5d
  - &dn-obsidian age1... # <-- Add new host key here

  # --- Admin / User Keys ---
  - &davidnuon age1rhufcqd6mjxrlxnh60rjgnwt69c33jqcfug539g84pyq84kvxgeqcr5s6u

creation_rules:
  - path_regex: hosts/dn-mememobile/secrets\.yaml$
    key_groups:
      - age:
          - *dn-mememobile
          - *davidnuon
  - path_regex: hosts/dn-obsidian/secrets\.yaml$
    key_groups:
      - age:
          - *dn-obsidian
          - *davidnuon # <-- Add creation rule here
```

#### Step 3: Create the Host's Encrypted File
```bash
sops hosts/dn-obsidian/secrets.yaml
```
Enter your secret keys in YAML format, for example:
```yaml
my-api-token: "super-secret-value"
harmonia-secret-key: |
  -----BEGIN PRIVATE KEY-----
  ...
  -----END PRIVATE KEY-----
```
Save and exit.

#### Step 4: Configure the Host to Load Secrets
Create `hosts/dn-obsidian/secrets.nix`:
```nix
{
  config,
  pkgs,
  ...
}: {
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    secrets = {
      "my-api-token" = {
        owner = "root";
        mode = "0400";
      };
    };
  };
}
```

Import `specialArgs.sops-nix.nixosModules.sops` and `./secrets.nix` in `hosts/dn-obsidian/default.nix`:
```nix
modules = [
  ...
  ./secrets.nix
  specialArgs.sops-nix.nixosModules.sops
  ...
];
```

---

### 3. Adding an Admin / Personal Key (Editing from your Laptop)

By default, only the target host's private SSH key can decrypt its `secrets.yaml`. If you want to view or edit secrets from your personal laptop without SSHing into the host first:

1. Generate a personal Age key (or convert your personal SSH key `~/.ssh/id_ed25519.pub`):
   ```bash
   ssh-to-age < ~/.ssh/id_ed25519.pub
   # Output: age1admin...
   ```
2. Add your personal key as `&admin` in `.sops.yaml`:
   ```yaml
   keys:
     - &admin age1admin...
     - &dn-mememobile age1ftz...

   creation_rules:
     - path_regex: hosts/dn-mememobile/secrets\.yaml$
       key_groups:
         - age:
             - *dn-mememobile
             - *admin
   ```
3. Update existing files with the new recipient key:
   ```bash
   sops updatekeys hosts/dn-mememobile/secrets.yaml
   ```
4. Tell SOPS on your laptop where your private key is:
   ```bash
   export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
   # Or using your SSH private key:
   export SOPS_AGE_SSH_KEY_FILE=~/.ssh/id_ed25519
   ```

---

## Referencing Secrets in NixOS Services

Once a secret is declared in `sops.secrets."<name>"`, its runtime path is accessible at:
```nix
config.sops.secrets."<name>".path
```
This resolves to `/run/secrets/<name>`.

### Example: Harmonia Binary Cache Key
In `hosts/dn-mememobile/secrets.yaml`:
```yaml
harmonia-secret-key: |
  dn-mememobile-1:sec...
```

In `mixins/nixcache/default.nix`:
```nix
services.harmonia.cache.signKeyPaths = lib.mkIf (config ? sops && config.sops.secrets ? "harmonia-secret-key") [
  config.sops.secrets."harmonia-secret-key".path
];
```

### Setting Ownership and Permissions
Services running under non-root users (like `postgres`, `caddy`, or a custom daemon) need appropriate read permissions:
```nix
sops.secrets."database-password" = {
  owner = "postgres";
  group = "postgres";
  mode = "0400";
};
```

---

## Troubleshooting & Tips

* **`error loading config: no matching creation rules found`**:
  Make sure the file path matches the `path_regex` in `.sops.yaml`. Run SOPS from the root of the repository so the relative paths align.
* **`could not decrypt with any key`**:
  Verify `/etc/ssh/ssh_host_ed25519_key` exists on the host, or that your personal Age key is set via `SOPS_AGE_KEY_FILE` or `SOPS_AGE_SSH_KEY_FILE`.
* **Testing without switching**:
  Test your Nix configuration evaluation anytime:
  ```bash
  nix eval .#nixosConfigurations.dn-mememobile.config.system.build.toplevel.drvPath
  ```
