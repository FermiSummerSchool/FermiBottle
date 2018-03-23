#! /bin/sh

curl -s -L http://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/release/heasoft-6.23src.tar.gz > heasoft-6.23.tar.gz
tar zxf heasoft-6.23.tar.gz
rm heasoft-6.23.tar.gz
cd heasoft-6.23/BUILD_DIR
./configure --prefix=$ASTROPFX CFLAGS=-fpic \
  --with-components="heacore tcltk attitude heatools Xspec ftools "
./hmake && ./hmake install
cd ..
rm -rf /heasoft-6.23
chmod -R g+rwx $ASTROPFX
