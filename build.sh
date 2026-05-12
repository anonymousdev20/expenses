#!/bin/bash

# Download and install Flutter
if [ ! -d "flutter" ]; then
  curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.6-stable.tar.xz
  tar xf flutter_linux_3.19.6-stable.tar.xz
fi

# Set Flutter path
export PATH="$PWD/flutter/bin:$PATH"

# Install dependencies
flutter pub get

# Build for web
flutter build web --release

echo "Build completed successfully!"
