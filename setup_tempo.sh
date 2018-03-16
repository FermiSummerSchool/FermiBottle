#! /bin/sh

git clone https://github.com/nanograv/tempo.git
mkdir -p $ASTROPFX/tempo
cd tempo && \
  bash prepare && \
  ./configure --prefix=$ASTROPFX/tempo && \
  make && make install
cd ../
rm -rf tempo
