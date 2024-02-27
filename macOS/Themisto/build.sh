#!/bin/bash
## Build script for cross-compiling Themisto for macOS x86-64 or arm64.
## Call this from `compile_in_docker.sh` unless you know what you're doing.

set -exo pipefail

VER=$1
if [[ -z $VER ]]; then
  echo "Error: specify version"
  exit;
fi

apt update
apt install -y cmake git libomp5 libomp-dev

mkdir /io/tmp
cd /io/tmp

git clone https://github.com/algbio/Themisto.git
cd Themisto
git checkout v${VER}

openmp=$(g++-9 -print-file-name=libgomp.a)
openmp=${openmp//\//\\/}
gsed -i "s/find_package(OpenMP REQUIRED)//g" CMakeLists.txt
gsed -i "s/OpenMP::OpenMP_CXX/$openmp/g" CMakeLists.txt

echo "target_compile_options(kmc_wrapper PRIVATE -fopenmp)
target_compile_options(pseudoalign PRIVATE -fopenmp)
target_compile_options(build_index PRIVATE -fopenmp)
" >> CMakeLists.txt

echo "target_compile_options(raduls_sse2 PRIVATE -fvisibility=hidden)
target_compile_options(raduls_sse41 PRIVATE -fvisibility=hidden)
target_compile_options(raduls_avx PRIVATE -fvisibility=hidden)
target_compile_options(raduls_avx2 PRIVATE -fvisibility=hidden)
" >> KMC/CMakeLists.txt

cd build

if [ "$ARCH" = "x86-64" ]; then
    cmake -DCMAKE_TOOLCHAIN_FILE="/io/$ARCH-toolchain.cmake" \
          -DCMAKE_C_FLAGS="-march=$ARCH -mtune=generic -m64 -fPIC -fPIE" \
          -DCMAKE_CXX_FLAGS="-march=$ARCH -mtune=generic -m64 -fPIC -fPIE" \
          -DBZIP2_LIBRARIES="/osxcross/SDK/MacOSX13.0.sdk/usr/lib/libbz2.tbd" -DBZIP2_INCLUDE_DIR="/osxcross/SDK/MacOSX13.0.sdk/usr/include" \
          -DZLIB_LIBRARY="/osxcross/SDK/MacOSX13.0.sdk/usr/lib/libz.tbd" -DZLIB_INCLUDE_DIR="/osxcross/SDK/MacOSX13.0.sdk/usr/include" \
	  -DMAX_KMER_LENGTH=31 \
          -DCMAKE_BUILD_WITH_FLTO=0  ..
elif [ "$ARCH" = "arm64" ]; then
    cmake -DCMAKE_TOOLCHAIN_FILE="/io/$ARCH-toolchain.cmake" \
          -DCMAKE_C_FLAGS="-arch $ARCH -mtune=generic -m64 -fPIC -fPIE" \
          -DCMAKE_CXX_FLAGS="-arch $ARCH -mtune=generic -m64 -fPIC -fPIE" \
          -DBZIP2_LIBRARIES="/osxcross/SDK/MacOSX13.0.sdk/usr/lib/libbz2.tbd" -DBZIP2_INCLUDE_DIR="/osxcross/SDK/MacOSX13.0.sdk/usr/include" \
          -DZLIB_LIBRARY="/osxcross/SDK/MacOSX13.0.sdk/usr/lib/libz.tbd" -DZLIB_INCLUDE_DIR="/osxcross/SDK/MacOSX13.0.sdk/usr/include" \
	  -DMAX_KMER_LENGTH=31 \
          -DCMAKE_BUILD_WITH_FLTO=0 ..
fi
make VERBOSE=1 -j

target=themisto_macOS-v${VER}
mkdir $target

cd ../../
cp Themisto/build/bin/pseudoalign $target/
cp Themisto/build/bin/build_index $target/
cp Themisto/LICENSE.txt $target/
cp Themisto/README.md $target/

tar -zcvf $target.tar.gz $target
cd ..
mv tmp/$target.tar.gz ./
rm -rf tmp
