#!/bin/bash

set -e

VER=$1

VER=$1
if [[ -z $VER ]]; then
  echo "Error: specify version"
  exit;
fi

mkdir tmp
cd tmp

target=mGEMS_macOS-v${VER}
mkdir $target

git clone https://github.com/PROBIC/mGEMS.git
cd mGEMS
git checkout v${VER}
git submodule update --init --recursive
mkdir build

gsed -i 's/find_package(LibLZMA)/set\(LIBLZMA_FOUND 0\)/g' CMakeLists.txt
cd build
cmake -DCMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -m64" -DCMAKE_C_FLAGS="-march=x86-64 -mtune=generic -m64" ..
gsed -i 's/BXZSTR_LZMA_SUPPORT 1/BXZSTR_LZMA_SUPPORT 0/g' external/bxzstr/include/config.hpp
make VERBOSE=1 -j

cd ../../
cp mGEMS/build/bin/* $target/
cp mGEMS/README.md $target/

# LICENSE and docs don't exist for old versionsb
set +e
cp mGEMS/LICENSE $target/
cp -rf mGEMS/docs $target/
set -e

tar -zcvf $target.tar.gz $target
cd ..
mv tmp/$target.tar.gz ./
rm -rf tmp
