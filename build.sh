#!/bin/bash
set -e

function build() {
  local archs=("$@")
  for arch in "${archs[@]}"
  do
    echo "* building for ${arch}"
    local command="ips2crash-${arch}"
    xcrun clang source/main.m \
      -o "products/${command}" \
      -mmacosx-version-min=11.0 \
      -F/System/Library/PrivateFrameworks \
      -framework Foundation \
      -framework OSAnalytics \
      -arch "$arch"
    strip -x "products/${command}"
  done
}

archs=('arm64' 'x86_64')

rm -rf products
mkdir -p "products"
build "${archs[@]}"

echo "* creating fat binary"
lipo -create products/ips2crash-* -output products/ips2crash
rm products/ips2crash-*

echo "* compressing for release"
tar -czf "products/ips2crash.tar.gz" "products/ips2crash";