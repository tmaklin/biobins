set -euxo pipefail

cp ../$2-toolchain.cmake ./

docker run \
  -v `pwd`:/io \
  --rm \
  -it \
  ghcr.io/shepherdjerred/macos-cross-compiler:latest \
  /bin/bash /io/build.sh $1 $2

rm $2-toolchain.cmake

