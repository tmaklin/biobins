VER=$1

VER=$1
if [[ -z $VER ]]; then
  echo "Error: specify version"
  exit;
fi

mkdir tmp
cd tmp

target=mSWEEP_macOS-v${VER}
mkdir $target

git clone https://github.com/PROBIC/mSWEEP.git
cd mSWEEP
git checkout v${VER}
mkdir build

gsed -i 's/find_package(LibLZMA)/set\(LIBLZMA_FOUND 0\)/g' CMakeLists.txt
cat CMakeLists.txt
cd build
cmake -DCMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -m64" -DCMAKE_C_FLAGS="-march=x86-64 -mtune=generic -m64" ..
make VERBOSE=1

cd ../../
cp mSWEEP/build/bin/mSWEEP $target/
cp mSWEEP/build/bin/matchfasta $target/
cp mSWEEP/LICENSE $target/
cp mSWEEP/README.md $target/

tar -zcvf $target.tar.gz $target
cd ..
mv tmp/$target.tar.gz ./
rm -rf tmp
