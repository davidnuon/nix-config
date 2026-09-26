#!/usr/bin/env python3
import json
import re
import sys

def main():
    if len(sys.argv) < 3:
        print("Usage: patch-grub.py <grub.cfg> <entries.json>", file=sys.stderr)
        sys.exit(1)

    grub_cfg_path = sys.argv[1]
    entries_json_path = sys.argv[2]

    with open(entries_json_path, "r", encoding="utf-8") as f:
        entries = json.load(f)

    with open(grub_cfg_path, "r", encoding="utf-8") as f:
        grub_cfg = f.read()

    # 1. Strip any existing dtb= parameter from linux command lines
    cleaned = re.sub(r"([ \t])dtb=[^ \t\n]+", "", grub_cfg)

    # 2. Extract baseline linux and initrd command lines from the primary menuentry
    linux_match = re.search(r"^[ \t]*linux[ \t]+.*$", cleaned, re.MULTILINE)
    initrd_match = re.search(r"^[ \t]*initrd[ \t]+.*$", cleaned, re.MULTILINE)

    if not linux_match or not initrd_match:
        print("Could not find linux or initrd lines in grub.cfg", file=sys.stderr)
        sys.exit(1)

    base_linux = linux_match.group(0).strip()
    base_initrd = initrd_match.group(0).strip()

    # 3. Build SMBIOS auto-detection block and new menu entries
    smbios_blocks = [
        "insmod smbios",
        "smbios -t 1 -s 4 --set sys_model",
        "smbios -t 1 -s 5 --set sys_family",
    ]
    new_entries = []

    for idx, e in enumerate(entries):
        menu_idx = idx * 2
        model = e.get("smbiosModel")
        if model:
            smbios_blocks.append(
                f'if [ "$sys_model" == "{model}" -o "$sys_family" == "{model}" ]; then set default="{menu_idx}"; fi'
            )

        name = e["name"]
        dtb = e["dtb"]
        extra = e.get("extraParams", "").strip()
        extra_str = f" {extra}" if extra else ""

        new_entries.append(
            f"""menuentry "NixOS Installer - {name}" --class installer --class nixos {{
  terminal_output console
  {base_linux}{extra_str}
  {base_initrd}
  devicetree ($root)/{dtb}
}}

menuentry "NixOS Installer - {name} (Safe Graphics)" --class installer --class nixos {{
  terminal_output console
  {base_linux}{extra_str} nomodeset
  {base_initrd}
  devicetree ($root)/{dtb}
}}"""
        )

    smbios_code = "\n" + "\n".join(smbios_blocks) + "\n"
    cleaned = re.sub(r"(set timeout=[0-9]+)", r"\1\n" + smbios_code, cleaned)

    # 4. Replace the first top-level menuentry block with our multi-platform entries
    first_menuentry_pattern = r"menuentry\s+['\"][^'\"]+['\"][^{]*\{[\s\S]*?\n\}"
    final_grub, count = re.subn(first_menuentry_pattern, "\n\n".join(new_entries), cleaned, count=1)

    if count == 0:
        print("Warning: could not replace first menuentry, appending new entries", file=sys.stderr)
        final_grub = cleaned + "\n\n" + "\n\n".join(new_entries)

    with open(grub_cfg_path, "w", encoding="utf-8") as f:
        f.write(final_grub)

    print(f"Successfully patched {grub_cfg_path} with {len(entries)} hardware targets")

if __name__ == "__main__":
    main()
