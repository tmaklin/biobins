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
target=mGEMS_linux-${VER}
path=/io/tmp/$target
mkdir $path
cp ../build/bin/* $path/
cp ../README.md $path/

# LICENSE and docs don't exist for old versions
set +e
cp ../LICENSE $path/
cp -rf ../docs $path/
set -e

cd /io/tmp
tar -zcvf $target.tar.gz $target
mv $target.tar.gz /io/
cd /io/
rm -rf tmp cache

