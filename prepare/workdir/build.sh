# install packages
install_pkg=$(realpath "./install_pkg.sh")
include_pkg=''
exclude_pkg=''
bash $install_pkg -i -d $(realpath 'linglong/sources') -p $PREFIX -I \"$include_pkg\" -E \"$exclude_pkg\"
export LD_LIBRARY_PATH=$PREFIX/lib/$TRIPLET:$LD_LIBRARY_PATH

# build ninja
cd /project/linglong/sources/ninja.git
cmake -Bbuild
cmake --build build -j$(nproc)
ninja="$(pwd)/build/ninja"

# build SDL2
cd /project/linglong/sources/SDL.git
mkdir build
cd build
../configure --prefix=$PREFIX \
             --enable-static=no
make -j$(nproc)
make install

# build irrlicht
cd /project/linglong/sources/irrlicht.git
cmake -Bbuild \
      -DCMAKE_BUILD_TYPE=Release \
      -G Ninja \
      -DCMAKE_MAKE_PROGRAM=$ninja \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib/$TRIPLET
cmake --build build -j4
cmake --install build

# build minetest
cd /project/linglong/sources/minetest.git
cmake -Bbuild \
      -DCMAKE_BUILD_TYPE=Release \
      -G Ninja \
      -DCMAKE_MAKE_PROGRAM=$ninja \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_RPATH=${PREFIX}/lib/${TRIPLET}
cmake --build build -j4
cmake --install build

# uninstall dev packages
bash $install_pkg -u -r '\-dev' -D
