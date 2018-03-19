#! /bin/sh

git clone https://github.com/nanograv/tempo.git
mkdir -p $TEMPO
cd tempo
bash prepare
./configure --prefix=$TEMPO
make && make install
cd ../
rm -rf tempo
