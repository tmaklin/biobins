VER=$1

VER=$1
if [[ -z $VER ]]; then
  echo "Error: specify version"
  exit;
fi

mkdir tmp
cd tmp

target=themisto_macOS-v${VER}
mkdir $target
git clone https://github.com/algbio/Themisto.git
cd Themisto
git checkout v${VER}

openmp=$(g++-9 -print-file-name=libgomp.a)
openmp=${openmp//\//\\/}
gsed -i "s/find_package(OpenMP REQUIRED)//g" CMakeLists.txt
gsed -i "s/OpenMP::OpenMP_CXX/$openmp/g" CMakeLists.txt

echo "target_compile_options(kmc_wrapper PRIVATE -fopenmp)
target_compile_options(pseudoalign PRIVATE -fopenmp)
target_compile_options(build_index PRIVATE -fopenmp)
" >> CMakeLists.txt

echo "target_compile_options(raduls_sse2 PRIVATE -fvisibility=hidden)
target_compile_options(raduls_sse41 PRIVATE -fvisibility=hidden)
target_compile_options(raduls_avx PRIVATE -fvisibility=hidden)
target_compile_options(raduls_avx2 PRIVATE -fvisibility=hidden)
" >> KMC/CMakeLists.txt

cd build
cmake -DCMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -m64 -fvisibility=hidden" -DCMAKE_C_FLAGS="-march=x86-64 -mtune=generic -m64 -fvisibility=hidden" -DCMAKE_C_COMPILER=$(which gcc-9) -DCMAKE_CXX_COMPILER=$(which g++-9) -DCMAKE_BUILD_ZLIB=1 -DCMAKE_BUILD_BZIP2=1 -DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -static-libgcc -fvisibility=hidden" -DCMAKE_MODULE_LINKER_FLAGS="-static-libstdc++ -static-libgcc -fvisibility=hidden"  ..
make VERBOSE=1 -j 4

cd ../../
cp Themisto/build/bin/pseudoalign $target/
cp Themisto/build/bin/build_index $target/
cp Themisto/LICENSE.txt $target/
cp Themisto/README.md $target/

tar -zcvf $target.tar.gz $target
cd ..
mv tmp/$target.tar.gz ./
rm -rf tmp
