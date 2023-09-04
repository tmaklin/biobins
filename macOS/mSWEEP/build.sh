#!/bin/bash

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

apt install -y cmake git

# Extract and enter source
mkdir /io/tmp && cd /io/tmp
git clone https://github.com/PROBIC/mSWEEP.git
cd mSWEEP
## git checkout v${VER}
git checkout cross-compilation-compatibility

# compile x86_64
mkdir build
cd build
if [ "$ARCH" = "x86-64" ]; then
    cmake -DCMAKE_TOOLCHAIN_FILE="/io/$ARCH-toolchain.cmake" -DCMAKE_C_FLAGS="-march=$ARCH -mtune=generic -m64 -fPIC -fPIE" -DCMAKE_CXX_FLAGS="-march=$ARCH -mtune=generic -m64 -fPIC -fPIE" -DCMAKE_BUILD_WITH_FLTO=0  ..
elif [ "$ARCH" = "arm64" ]; then
    cmake -DCMAKE_TOOLCHAIN_FILE="/io/$ARCH-toolchain.cmake" -DCMAKE_C_FLAGS="-arch $ARCH -mtune=generic -m64 -fPIC -fPIE" -DCMAKE_CXX_FLAGS="-arch $ARCH -mtune=generic -m64 -fPIC -fPIE" -DCMAKE_BUILD_WITH_FLTO=0  ..
fi
make VERBOSE=1 -j

## gather the stuff to distribute
target=mSWEEP_macos-$ARCH-v${VER}
target=$(echo $target | sed 's/x86-64/x86_64/g')
path=/io/tmp/$target
mkdir $path
cp ../build/bin/mSWEEP $path/
cp ../CHANGELOG.md $path/
cp ../README.md $path/
cp ../LICENSE $path/
cd /io/tmp
tar -zcvf $target.tar.gz $target
mv $target.tar.gz /io/
cd /io/
rm -rf tmp cache

