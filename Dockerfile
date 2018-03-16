FROM centos:6

MAINTAINER "Fermi LAT Collaboration"

RUN yum update -y && \
    yum install -y \
      bzip2 make \
      patch sudo \
      tar git \
      which \
      vim emacs \
      libXext-devel \
      libXrender-devel \
      libSM-devel \
      libX11-devel \
      mesa-libGL-devel \
      gcc gcc-c++ \
      gcc-gfortran \
      autoconf automake \
      perl && \
yum clean all && \
rm -rf /var/cache/yum

ENV ASTROPFX $HOME/astrosoft
ENV CONDAPFX $HOME/anaconda
ENV CONDAEXE $CONDAPFX/bin/conda
ENV TEMPO2 /usr/share/tempo2
ENV CONDAINSTFERMI "$CONDAEXE install -y -n fermi -c conda-forge -c fermi_dev_externals "
RUN mkdir -p $ASTROPFX

COPY setup_anaconda.sh $HOME/setup_anaconda.sh
RUN sh setup_anaconda.sh && rm setup_anaconda.sh

# COPY setup_tempo.sh $HOME/setup_tempo.sh
# RUN sh setup_tempo.sh && rm setup_tempo.sh

COPY setup_tempo2.sh $HOME/setup_tempo2.sh
RUN sh setup_tempo2.sh && rm setup_tempo2.sh

# RUN curl -s -L http://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/release/heasoft-6.23src.tar.gz > heasoft.tar.gz && \
#   tar zxf heasoft.tar.gz

# RUN conda install --yes -c conda-forge -c fermi_dev_externals fermitools

# RUN ${HOME}/anaconda/bin/conda install --yes -c conda-forge -c fermi_dev_externals WHATEVER_WE_NAME_SCIENCETOOLS!!!!!
# RUN ${HOME}/anaconda/bin/conda install --yes -c conda-forge -c fermi_dev_externals ape

VOLUME ["/data"]
# USER fermistudent
CMD [ "/bin/bash" ]

