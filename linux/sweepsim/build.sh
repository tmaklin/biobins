#!/bin/bash

set -e

name=sweepsim
repository=https://github.com/tmaklin/sweepsim.git
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

# Extract and enter source
mkdir /io/tmp && cd /io/tmp
git clone -o $name $repository
cd $name
git checkout v${VER}

# compile
mkdir build
cd build
cmake -DCMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -m64" -DCMAKE_C_FLAGS="-march=x86-64 -mtune=generic -m64" ..
make VERBOSE=1

# gather the stuff to distribute
target=$name-v${VER}_linux_x86-64
path=/io/tmp/$target
mkdir $path
cp bin/* $path/
cp ../README.md $path/
cp ../LICENSE $path/
cd /io/tmp
tar -zcvf $target.tar.gz $target
mv $target.tar.gz /io/
cd /io/
rm -rf tmp cache

