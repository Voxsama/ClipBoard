#!/bin/bash
# ──────────────────────────────────────────────────────────────
# ClipBoard – Build Script
# Compiles with Swift Package Manager and packages into a .app bundle.
# Usage: ./build.sh
# ──────────────────────────────────────────────────────────────
set -euo pipefail

APP_NAME="ClipBoard"
BUILD_CONFIG="release"
BUILD_DIR=".build/${BUILD_CONFIG}"
APP_BUNDLE="${APP_NAME}.app"

echo "🔨 Building ${APP_NAME} (${BUILD_CONFIG})…"
swift build -c "${BUILD_CONFIG}"

echo ""
echo "📦 Creating ${APP_BUNDLE}…"
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy executable
cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"

# Copy Info.plist
cp "Resources/Info.plist" "${APP_BUNDLE}/Contents/"

# Ad-hoc code sign (required on Apple Silicon)
echo "🔏 Signing…"
codesign --force --deep --sign - "${APP_BUNDLE}" 2>/dev/null || true

echo ""
echo "✅  Build complete!"
echo ""
echo "   To launch:    open ${APP_BUNDLE}"
echo "   To install:   cp -R ${APP_BUNDLE} /Applications/"
echo ""
echo "⚠️  On first launch, macOS will ask for Accessibility permission"
echo "   (System Settings → Privacy & Security → Accessibility)."
echo "   This is required for the ⌘⇧V global shortcut."
