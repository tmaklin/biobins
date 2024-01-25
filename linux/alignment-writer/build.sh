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

yum -y install git

export PATH="/usr/bin:"$PATH

# Extract and enter source
mkdir /io/tmp && cd /io/tmp
git clone https://github.com/tmaklin/alignment-writer
cd alignment-writer
git checkout v${VER}

# compile
mkdir build
cd build
cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -m64" -DCMAKE_C_FLAGS="-march=x86-64 -mtune=generic -m64" -DCMAKE_WITH_FLTO=1 -DCMAKE_WITH_NATIVE_INSTRUCTIONS=OFF ..
make VERBOSE=1

# gather the stuff to distribute
target=alignment-writer_linux-x86_64-v${VER}
path=/io/tmp/$target
mkdir $path
cp ../build/bin/alignment-writer $path/
cp ../README.md $path/
cp ../LICENSE $path/
cd /io/tmp
tar -zcvf $target.tar.gz $target
mv $target.tar.gz /io/
cd /io/
rm -rf tmp cache

