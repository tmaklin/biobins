name=sweepsim
repository=https://github.com/tmaklin/sweepsim.git
VER=$1

VER=$1
if [[ -z $VER ]]; then
  echo "Error: specify version"
  exit;
fi

mkdir tmp
cd tmp

target=$name-v${VER}_macOS_x86-64
mkdir $target

git clone -o $name $repository

cd $name
git checkout v${VER}
mkdir build
cd build
cmake -DCMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -m64" -DCMAKE_C_FLAGS="-march=x86-64 -mtune=generic -m64" ..
make VERBOSE=1

cd ../../
cp $name/build/bin/* $target/
cp $name/LICENSE $target/
cp $name/README.md $target/

tar -zcvf $target.tar.gz $target
cd ..
mv tmp/$target.tar.gz ./
rm -rf tmp
