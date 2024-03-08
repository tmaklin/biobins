#!/bin/bash
## Build script for cross-compiling cpprate for macOS x86-64 or arm64.
## Call this from `compile_in_docker.sh` unless you know what you're doing.

set -exo pipefail

VER=$1
if [[ -z $VER ]]; then
  echo "Error: specify version"
  exit;
fi

ARCH=$2
if [[ -z $ARCH ]]; then
  echo "Error: specify architecture (one of x86-64,arm64)"
  exit;
fi

apt update
apt install -y cmake git libomp5 libomp-dev

# Extract and enter source
mkdir /io/tmp && cd /io/tmp
git clone https://github.com/tmaklin/cpprate.git
cd cpprate
git checkout ${VER}

# compile x86_64
mkdir build
cd build
target_arch=""
if [ "$ARCH" = "x86-64" ]; then
    cmake -DCMAKE_TOOLCHAIN_FILE="/io/$ARCH-toolchain.cmake" \
          -DCMAKE_C_FLAGS="-march=$ARCH -mtune=generic -m64 -fPIC -fPIE" \
          -DCMAKE_CXX_FLAGS="-march=$ARCH -mtune=generic -m64 -fPIC -fPIE" \
          -DBZIP2_LIBRARIES="/osxcross/SDK/MacOSX13.0.sdk/usr/lib/libbz2.tbd" -DBZIP2_INCLUDE_DIR="/osxcross/SDK/MacOSX13.0.sdk/usr/include" \
          -DZLIB_LIBRARY="/osxcross/SDK/MacOSX13.0.sdk/usr/lib/libz.tbd" -DZLIB_INCLUDE_DIR="/osxcross/SDK/MacOSX13.0.sdk/usr/include" \
          -DCMAKE_BUILD_WITH_FLTO=0 \
          -DCMAKE_BUILD_EXECUTABLE=1  ..
    target_arch="x86_64-apple-darwin22"
elif [ "$ARCH" = "arm64" ]; then
    cmake -DCMAKE_TOOLCHAIN_FILE="/io/$ARCH-toolchain.cmake" \
          -DCMAKE_C_FLAGS="-arch $ARCH -mtune=generic -m64 -fPIC -fPIE" \
          -DCMAKE_CXX_FLAGS="-arch $ARCH -mtune=generic -m64 -fPIC -fPIE" \
          -DBZIP2_LIBRARIES="/osxcross/SDK/MacOSX13.0.sdk/usr/lib/libbz2.tbd" -DBZIP2_INCLUDE_DIR="/osxcross/SDK/MacOSX13.0.sdk/usr/include" \
          -DZLIB_LIBRARY="/osxcross/SDK/MacOSX13.0.sdk/usr/lib/libz.tbd" -DZLIB_INCLUDE_DIR="/osxcross/SDK/MacOSX13.0.sdk/usr/include" \
          -DCMAKE_BUILD_WITH_FLTO=0 \
          -DCMAKE_BUILD_EXECUTABLE=1  ..
    target_arch="arm64-apple-darwin22"
fi
make VERBOSE=1 -j

# gather the stuff to distribute
target=cpprate-${VER}-$target_arch
path=/io/tmp/$target
mkdir -p $path
cp ../build/bin/cpprate $path/
cp ../README.md $path/
cp ../LICENSE $path/
cd /io/tmp
tar -zcvf $target.tar.gz $target
mv $target.tar.gz /io/
cd /io/
rm -rf tmp cache
