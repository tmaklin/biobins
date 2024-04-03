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

yum -y install git upx

export CARGO_HOME="/.cargo"
export RUSTUP_HOME="/.rustup"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
chmod +x rustup.sh
./rustup.sh -y --profile minimal --default-toolchain nightly --component rust-src
. /.cargo/env

export PATH="/usr/bin:"$PATH

# Extract and enter source
mkdir /io/tmp && cd /io/tmp
git clone https://github.com/tmaklin/panaani.git
cd panaani
git checkout ${VER}

# compile
hostarch=$(rustc -vV | grep "^host" | cut -f2 -d':' | sed 's/^[[:space:]]*//g')
RUSTFLAGS="-Zlocation-detail=none" cargo +nightly build -Z build-std=std,panic_abort --target $hostarch --release
ls -lh target/x86_64-unknown-linux-gnu/release/

# gather the stuff to distribute
target=panaani-${VER}-$hostarch
path=/io/tmp/$target
mkdir -p $path
cp target/$hostarch/release/panaani $path/
cp README.md $path/
cp LICENSE $path/
cd /io/tmp
tar -zcvf $target.tar.gz $target
mv $target.tar.gz /io/
cd /io/
rm -rf tmp cache
