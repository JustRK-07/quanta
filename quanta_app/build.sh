#!/bin/bash

# Exit on error
set -e

if [[ -z "${QUANTA_API_BASE_URL:-}" ]]; then
  echo "QUANTA_API_BASE_URL must be set for a deployed web build." >&2
  echo "Example: QUANTA_API_BASE_URL=https://api.example.com ./build.sh" >&2
  exit 1
fi

echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

echo "Flutter installed at: `which flutter`"
flutter doctor -v

echo "Enabling web support..."
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get

echo "Building specific web target..."
# Note: Using html renderer for better compatibility, or canvaskit for performance
flutter build web --release \
  --dart-define=QUANTA_API_BASE_URL="$QUANTA_API_BASE_URL"

echo "Build complete."
