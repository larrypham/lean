#!/bin/bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: scripts/build_dmg.sh [arm64|x86_64]

Builds Lean in Release configuration and creates a DMG in dist/.

Environment variables:
  VERSION             Marketing version (defaults to project setting)
  BUILD_NUMBER        Build number (defaults to project setting)
  SIGNING_IDENTITY    Developer ID Application identity (defaults to ad-hoc: -)
  DEVELOPMENT_TEAM    Apple Developer team ID (required for Developer ID signing)
  NOTARY_PROFILE      notarytool Keychain profile; notarizes and staples the DMG
  OUTPUT_DIR          Artifact directory (defaults to <repo>/dist)
  KEEP_BUILD_DIR      Set to 1 to retain the temporary build directory
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
fi

ARCH="${1:-$(uname -m)}"
if [[ "$ARCH" != "arm64" && "$ARCH" != "x86_64" ]]; then
    echo "error: architecture must be arm64 or x86_64" >&2
    exit 2
fi

for tool in xcodebuild hdiutil codesign ditto; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "error: required tool '$tool' was not found" >&2
        exit 1
    fi
done
if [[ ! -x /usr/libexec/PlistBuddy ]]; then
    echo "error: required tool '/usr/libexec/PlistBuddy' was not found" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT="$REPO_ROOT/Lean.xcodeproj"
OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT/dist}"
SIGNING_IDENTITY="${SIGNING_IDENTITY:--}"
BUILD_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/lean-release.XXXXXX")"

cleanup() {
    if [[ "${KEEP_BUILD_DIR:-0}" == "1" ]]; then
        echo "Build directory retained at $BUILD_ROOT"
    else
        rm -rf "$BUILD_ROOT"
    fi
}
trap cleanup EXIT

project_setting() {
    xcodebuild -project "$PROJECT" -scheme Lean -configuration Release -showBuildSettings \
        | awk -F ' = ' -v key="$1" '$1 ~ "^[[:space:]]*" key "$" { print $2; exit }'
}

VERSION="${VERSION:-$(project_setting MARKETING_VERSION)}"
BUILD_NUMBER="${BUILD_NUMBER:-$(project_setting CURRENT_PROJECT_VERSION)}"
if [[ -z "$VERSION" || -z "$BUILD_NUMBER" ]]; then
    echo "error: could not determine VERSION or BUILD_NUMBER" >&2
    exit 1
fi

if [[ "$SIGNING_IDENTITY" != "-" && -z "${DEVELOPMENT_TEAM:-}" ]]; then
    echo "error: DEVELOPMENT_TEAM is required with a Developer ID identity" >&2
    exit 1
fi
if [[ -n "${NOTARY_PROFILE:-}" && "$SIGNING_IDENTITY" == "-" ]]; then
    echo "error: notarization requires a Developer ID SIGNING_IDENTITY" >&2
    exit 1
fi

ARCHIVE_PATH="$BUILD_ROOT/Lean-$ARCH.xcarchive"
BUILD_ARGS=(
    -project "$PROJECT"
    -scheme Lean
    -configuration Release
    -destination "generic/platform=macOS"
    -archivePath "$ARCHIVE_PATH"
    archive
    "ARCHS=$ARCH"
    "ONLY_ACTIVE_ARCH=NO"
    "MARKETING_VERSION=$VERSION"
    "CURRENT_PROJECT_VERSION=$BUILD_NUMBER"
)

if [[ "$SIGNING_IDENTITY" == "-" ]]; then
    BUILD_ARGS+=("CODE_SIGN_IDENTITY=-" "CODE_SIGN_STYLE=Manual")
else
    BUILD_ARGS+=(
        "CODE_SIGN_IDENTITY=$SIGNING_IDENTITY"
        "CODE_SIGN_STYLE=Manual"
        "DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM"
    )
fi

echo "Building Lean $VERSION ($BUILD_NUMBER) for $ARCH..."
xcodebuild "${BUILD_ARGS[@]}"

APP_PATH="$ARCHIVE_PATH/Products/Applications/Lean.app"
if [[ ! -d "$APP_PATH" ]]; then
    echo "error: archive did not contain Lean.app" >&2
    exit 1
fi

ACTUAL_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist")"
ACTUAL_BUILD="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP_PATH/Contents/Info.plist")"
if [[ "$ACTUAL_VERSION" != "$VERSION" || "$ACTUAL_BUILD" != "$BUILD_NUMBER" ]]; then
    echo "error: built version $ACTUAL_VERSION ($ACTUAL_BUILD) does not match requested version" >&2
    exit 1
fi

codesign --verify --deep --strict --verbose=2 "$APP_PATH"

STAGING_DIR="$BUILD_ROOT/dmg"
mkdir -p "$STAGING_DIR"
ditto "$APP_PATH" "$STAGING_DIR/Lean.app"
ln -s /Applications "$STAGING_DIR/Applications"

mkdir -p "$OUTPUT_DIR"
DMG_PATH="$OUTPUT_DIR/Lean-$VERSION-$ARCH.dmg"
rm -f "$DMG_PATH"
hdiutil create \
    -volname "Lean $VERSION" \
    -srcfolder "$STAGING_DIR" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -ov \
    "$DMG_PATH"

if [[ "$SIGNING_IDENTITY" != "-" ]]; then
    codesign --force --sign "$SIGNING_IDENTITY" --timestamp "$DMG_PATH"
fi

if [[ -n "${NOTARY_PROFILE:-}" ]]; then
    echo "Submitting DMG for notarization..."
    xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
    xcrun stapler staple "$DMG_PATH"
    xcrun stapler validate "$DMG_PATH"
fi

hdiutil verify "$DMG_PATH"
shasum -a 256 "$DMG_PATH" > "$DMG_PATH.sha256"
echo "Created $DMG_PATH"
echo "Checksum: $DMG_PATH.sha256"
