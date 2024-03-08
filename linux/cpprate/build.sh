#!/bin/bash

# Based on https://pmelsted.wordpress.com/2015/10/14/building-binaries-for-bioinformatics/

set -e

VER=$1
if [[ -z $VER ]]; then
  echo "Error: specify version"
  exit;
fi

# Activate Holy Build Box environment.
source /hbb_exe/activate
export LDFLAGS="-L/lib64 -static-libstdc++"
set -x

yum -y install git libomp libomp-devel

export PATH="/usr/bin:"$PATH

# Extract and enter source
mkdir /io/tmp && cd /io/tmp
git clone https://github.com/tmaklin/cpprate.git
cd cpprate
git checkout ${VER}

# compile
mkdir build
cd build
cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -m64 -ffunction-sections -fdata-sections -Wl,-gc-sections -s -Wl,--strip-all -fmerge-all-constants -Wl,-z,norelro -fPIE -fPIC -DNDEBUG" -DCMAKE_C_FLAGS="-march=x86-64 -mtune=generic -m64 -ffunction-sections -fdata-sections -Wl,-gc-sections -s -Wl,--strip-all -fmerge-all-constants -Wl,-z,norelro -fPIE -fPIC -DNDEBUG" -DCMAKE_BUILD_EXECUTABLE=1 -DCMAKE_BUILD_WITH_FLTO=1 ..
make VERBOSE=1

# gather the stuff to distribute
target=cpprate-${VER}-$(gcc -v 2>&1 | grep "^Target" | cut -f2 -d':' | sed 's/[[:space:]]*//g')
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
