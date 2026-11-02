INSERT INTO Users (userName, fullName, emailAddress, password)
VALUES ('admin', 'Hydra Administrator', 'admin@localhost', '')
ON CONFLICT (userName) DO NOTHING;

INSERT INTO UserRoles (userName, role)
VALUES ('admin', 'admin')
ON CONFLICT DO NOTHING;

INSERT INTO Projects (name, displayName, description, owner, enabled, hidden)
VALUES ('nix-config', 'Nix Config', 'NixOS configurations', 'admin', 1, 0)
ON CONFLICT (name) DO NOTHING;

INSERT INTO Jobsets (name, project, description, type, flake, checkInterval, emailOverride, enabled, enableEmail)
VALUES ('x86-hosts', 'nix-config', 'Build all x86 NixOS configurations', 1, 'github:davidnuon/nix-config/main', 86400, '', 1, 0)
ON CONFLICT (project, name) DO UPDATE SET
  flake = EXCLUDED.flake,
  type = EXCLUDED.type,
  enabled = EXCLUDED.enabled;
