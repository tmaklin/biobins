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
git clone https://github.com/PROBIC/mGEMS.git
cd mGEMS
git checkout ${VER}
git submodule update --init --recursive

# compile
mkdir build
cd build
cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -m64" -DCMAKE_C_FLAGS="-march=x86-64 -mtune=generic -m64" ..
make VERBOSE=1 -j

# gather the stuff to distribute
target=mGEMS-${VER}-$(gcc -v 2>&1 | grep "^Target" | cut -f2 -d':' | sed 's/[[:space:]]*//g')
path=/io/tmp/$target
mkdir $path
cp -rf ../docs $path/docs
cp ../build/bin/mGEMS $path/
cp ../README.md $path/
cp ../LICENSE $path/
cd /io/tmp
tar -zcvf $target.tar.gz $target
mv $target.tar.gz /io/
cd /io/
rm -rf tmp cache
