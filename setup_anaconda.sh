#! /bin/sh

curl -s -L https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh > anaconda.sh
bash anaconda.sh -b -p ${CONDAPFX}
rm anaconda.sh
# echo "export PATH=${CONDAPFX}/bin:$PATH" >> ${HOME}/.bashrc
export PATH=${CONDAPFX}/bin:$PATH
conda install --yes -c conda-forge gosu tini
conda create --name fermi -c conda-forge -c fermi_dev_externals \
  fermipy \
  fermitools \
  fermitools-data \
  jupyter \
  libpng \
  pgplot \
  pyyaml \
  --yes
rm -rf ${CONDAPFX}/pkgs/*
chown -R :wheel /opt/anaconda
chmod -R g+rwx /opt/anaconda
