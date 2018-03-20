FROM centos:6 as builder

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
  libXt-devel \
  mesa-libGL-devel \
  gcc gcc-c++ \
  gcc-gfortran \
  autoconf automake \
  perl perl-ExtUtils-MakeMaker\
  ncurses-devel \
  readline-devel \
  && \
yum clean all && \
rm -rf /var/cache/yum

# Top Level Environment variables
ENV ASTROPFX /home/astrosoft
RUN mkdir -p $ASTROPFX
ENV CONDAPFX /home/anaconda

# Anaconda Fermitools, and other conda packages
COPY setup_anaconda.sh $HOME/setup_anaconda.sh
RUN sh setup_anaconda.sh && rm setup_anaconda.sh

# Fermitools prefix
ENV FERMIPFX $CONDAPFX/envs/fermi
ENV LD_LIBRARY_PATH $FERMIPFX/lib

# Tempo
ENV TEMPO $ASTROPFX/tempo
COPY setup_tempo.sh $HOME/setup_tempo.sh
RUN sh setup_tempo.sh && rm setup_tempo.sh

# Tempo2
ENV TEMPO2 $ASTROPFX/tempo2/T2runtime
COPY setup_tempo2.sh $HOME/setup_tempo2.sh
RUN sh setup_tempo2.sh && rm setup_tempo2.sh

# Presto
# ENV PRESTO $ASTROPFX/presto
# COPY setup_presto.sh $HOME/setup_presto.sh
# RUN sh setup_presto.sh && rm setup_presto.sh

# Heasarc Ftools
COPY setup_ftools.sh $HOME/setup_ftools.sh
RUN sh setup_ftools.sh && rm setup_ftools.sh

# RUN echo -e "PATH=${CONDAPFX}/bin:${ASTROPFX}/bin:$PATH\n\
# HEADAS=${ASTROPFX}/x86_64-unknown-linux-gnu-libc2.12\n\
# alias heainit=source $HEADAS/heainit.sh" > /home/.bashrc

# copy build products into new layer
FROM centos:6
MAINTAINER "Fermi LAT Collaboration"
RUN yum update -y && \
yum install -y \
  bzip2 make \
  patch sudo \
  tar git \
  which \
  vim emacs \
  libXext \
  libXrender \
  libSM \
  libX11 \
  libXt \
  mesa-libGL \
  gcc gcc-c++ \
  gcc-gfortran \
  perl \
  ncurses\
  readline\
&& \
yum clean all && \
rm -rf /var/cache/yum
COPY --from=builder /home /home
COPY entrypoint /opt/docker/bin/entrypoint
VOLUME ["/data"]
# USER fermistudent
ENTRYPOINT ["/opt/docker/bin/entrypoint"]
CMD [ "/bin/bash" ]

