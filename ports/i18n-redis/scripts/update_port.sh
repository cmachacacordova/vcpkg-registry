#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <tag-or-commit>" >&2
    exit 1
fi

TAG="$1"
REPO="https://github.com/cmachacacordova/i18n-redis.git"

PORT_DIR="$(dirname "$0")/.."
GIT_DIR="$PORT_DIR/.gitrepo"

# Try to resolve the tag locally; fall back to remote
COMMIT=$(git --git-dir="$GIT_DIR" rev-parse "$TAG" 2>/dev/null || true)
if [[ -z "$COMMIT" ]]; then
    COMMIT=$(git ls-remote "$REPO" "$TAG" | awk '{print $1}')
    if [[ -z "$COMMIT" ]]; then
        COMMIT="$TAG"
    fi
fi

SHA512=$(git --git-dir="$GIT_DIR" archive --format=tar "$COMMIT" | sha512sum | awk '{print $1}')

# Update portfile.cmake
sed -i -E "s|REF [0-9a-f]+ # tag [^ ]+|REF $COMMIT # tag $TAG|" portfile.cmake
sed -i -E "s|SHA512 [0-9a-f]{128}|SHA512 $SHA512|" portfile.cmake

# Update version in vcpkg.json
VERSION=${TAG#v}
sed -i -E "s/(\"version\": \"?)[^\"]+(\")/\1$VERSION\2/" vcpkg.json

echo "Updated to $TAG" >&2
echo "Commit: $COMMIT" >&2
echo "SHA512: $SHA512" >&2
