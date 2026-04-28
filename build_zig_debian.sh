#!/bin/bash
set -e

ZIG_VERSION=$1
BUILD_VERSION=$2

if [ -z "$ZIG_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: ./build_zig_debian.sh <ZIG_VERSION> <BUILD_VERSION>"
    exit 1
fi

declare -a arr=("bookworm" "trixie" "forky" "sid")

for DEBIAN_DIST in "${arr[@]}"
do
  echo "--- Building for $DEBIAN_DIST ---"
  FULL_VERSION="${ZIG_VERSION}-${BUILD_VERSION}+${DEBIAN_DIST}"
  DEB_FILENAME="zig-master_${FULL_VERSION}_amd64.deb"
  
  # Build the container
  docker build . -t "zig-master-$DEBIAN_DIST" \
    --build-arg ZIG_VERSION="$ZIG_VERSION" \
    --build-arg DEBIAN_DIST="$DEBIAN_DIST" \
    --build-arg BUILD_VERSION="$BUILD_VERSION" \
    --build-arg FULL_VERSION="${FULL_VERSION}_amd64"

  # Extract the .deb file only
  id="$(docker create "zig-master-$DEBIAN_DIST")"
  docker cp "$id:/zig-master_${FULL_VERSION}_amd64.deb" "./$DEB_FILENAME"
  docker rm "$id"
  
  echo "Created: $DEB_FILENAME"
done
