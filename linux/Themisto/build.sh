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

# Extract and enter source
mkdir /io/tmp && cd /io/tmp

export PATH="/usr/bin:"$PATH
git clone https://github.com/algbio/Themisto
cd Themisto
git checkout v${VER}

# compile
cd build
cmake -DCMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -m64" -DCMAKE_C_FLAGS="-march=x86-64 -mtune=generic -m64" -DCMAKE_BUILD_BZIP2=1 -DCMAKE_BUILD_TYPE=Release ..
make VERBOSE=1 -j 4

# gather the stuff to distribute
target=themisto_linux-v${VER}
path=/io/tmp/$target
mkdir $path
cp bin/build_index $path/
cp bin/pseudoalign $path/
cp ../README.md $path/
cp ../LICENSE.txt $path/
cd /io/tmp
tar -zcvf $target.tar.gz $target
mv $target.tar.gz /io/
cd /io/
rm -rf tmp cache
