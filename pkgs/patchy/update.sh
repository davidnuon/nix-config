#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/package.nix"

echo "Checking latest release of SethRobinson/Patchy..."
LATEST_TAG=$(curl -s "https://api.github.com/repos/SethRobinson/Patchy/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')

if [ -z "$LATEST_TAG" ]; then
    echo "Error: Could not retrieve latest tag from GitHub API." >&2
    exit 1
fi

VERSION="${LATEST_TAG#v}"
echo "Latest release tag: $LATEST_TAG (version: $VERSION)"

CURRENT_VERSION=$(grep -Po 'version = "\K.*?(?=";)' "$PACKAGE_FILE" || true)
echo "Current version in package.nix: $CURRENT_VERSION"

if [ "$CURRENT_VERSION" = "$VERSION" ]; then
    echo "Patchy is already at the latest version ($VERSION)."
    exit 0
fi

echo "Prefetching source archive..."
HASH_BASE32=$(nix-prefetch-url --unpack "https://github.com/SethRobinson/Patchy/archive/refs/tags/${LATEST_TAG}.tar.gz")
HASH_SRI=$(nix hash convert --to sri "sha256:$HASH_BASE32" 2>/dev/null || nix-hash --type sha256 --to-sri "$HASH_BASE32")

echo "New SRI hash: $HASH_SRI"

sed -i -E "s/version = \"[^\"]+\";/version = \"$VERSION\";/" "$PACKAGE_FILE"
sed -i -E "s|hash = \"[^\"]+\";|hash = \"$HASH_SRI\";|" "$PACKAGE_FILE"

echo "Successfully updated $PACKAGE_FILE to version $VERSION!"
