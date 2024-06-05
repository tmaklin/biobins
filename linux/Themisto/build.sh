#!/bin/bash
## Build script for compiling Themisto for Linux x86-64.
## Call this from `compile.sh` with the desired tag as the argument.
## Adapted from the scripts in https://github.com/tmaklin/biobins

set -e

VER=$1
if [[ -z $VER ]]; then
  echo "Error: specify version"
  exit;
fi

## Install git and gcc-10
yum -y install git devtoolset-10-*

## Change hbb environment to use gcc-10
sed 's/DEVTOOLSET_VERSION=9/DEVTOOLSET_VERSION=10/g' /hbb/activate_func.sh > /hbb/activate_func_10.sh
mv --force /hbb/activate_func_10.sh /hbb/activate_func.sh

# Activate Holy Build Box environment.
source /hbb_exe/activate
export LDFLAGS="-L/lib64 -static-libstdc++"
set -x

## Setup paths so cmake finds the correct toolchain
export CC="/opt/rh/devtoolset-10/root/usr/bin/gcc"
export CXX="/opt/rh/devtoolset-10/root/usr/bin/g++"

## Setup rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
chmod +x rustup.sh
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
./rustup.sh -y --default-toolchain stable --profile minimal
. "$HOME/.cargo/env"
rustup target add x86_64-unknown-linux-gnu

## Extract and enter source
mkdir /io/tmp && cd /io/tmp

## Clone Themisto
git clone https://github.com/tmaklin/Themisto
cd Themisto
git checkout ${VER}
git submodule update --init --recursive

## Specify target for cargo
mkdir -p ggcat/.cargo
echo "[build]" >> ggcat/.cargo/config.toml
echo "target = \"x86_64-unknown-linux-gnu\"" >> ggcat/.cargo/config.toml

sed 's/target\/release/target\/x86_64-unknown-linux-gnu\/release/g' ggcat/crates/capi/ggcat-cpp-api/Makefile > Makefile.tmp
mv Makefile.tmp ggcat/crates/capi/ggcat-cpp-api/Makefile

## Compile
cd build
cmake -DCMAKE_C_FLAGS="-march=x86-64 -mtune=generic -m64" \
      -DCMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -m64" \
      -DCMAKE_BUILD_TYPE=Release \
      -DROARING_DISABLE_NATIVE=ON \
      -DMAX_KMER_LENGTH=31 ..

make VERBOSE=1 -j

## Gather distributable
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
