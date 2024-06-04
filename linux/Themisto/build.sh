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
git checkout ${VER}
git submodule update --init --recursive

# compile
cd build
cmake -DCMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -m64" -DCMAKE_C_FLAGS="-march=x86-64 -mtune=generic -m64" -DCMAKE_BUILD_TYPE=Release -DMAX_KMER_LENGTH=31 ..
make VERBOSE=1 -j

# gather the stuff to distribute
target=themisto-${VER}-$(gcc -v 2>&1 | grep "^Target" | cut -f2 -d':' | sed 's/[[:space:]]*//g')
path=/io/tmp/$target
mkdir $path
cp ../build/bin/themisto $path/
cp ../README.md $path/
cp ../LICENSE.txt $path/
cd /io/tmp
tar -zcvf $target.tar.gz $target
mv $target.tar.gz /io/
cd /io/
rm -rf tmp cache
