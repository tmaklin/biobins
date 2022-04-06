#!/bin/bash

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
name=unmulti
git clone -o $name https://github.com/tmaklin/unmulti.git
cd $name
git checkout v${VER}

# compile
mkdir build
cd build
cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -m64" -DCMAKE_C_FLAGS="-march=x86-64 -mtune=generic -m64" ..
make VERBOSE=1

# gather the stuff to distribute
target=$name-v${VER}_linux_x86-64
path=/io/tmp/$target
mkdir $path
cp bin/unmulti $path/
cp ../README.md $path/
cp ../LICENSE $path/
cd /io/tmp
tar -zcvf $target.tar.gz $target
mv $target.tar.gz /io/
cd /io/
rm -rf tmp cache

