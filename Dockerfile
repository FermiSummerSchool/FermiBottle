FROM centos:6 as builder

RUN yum update -y && \
yum install -y \
  autoconf \
  automake \
  bzip2 \
  emacs \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  git \
  libXext-devel \
  libXrender-devel \
  libSM-devel \
  libX11-devel \
  libXt-devel \
  make \
  mesa-libGL-devel \
  ncurses-devel \
  patch \
  perl \
  perl-ExtUtils-MakeMaker \
  readline-devel \
  sudo \
  tar \
  vim \
  which \
  && \
yum clean all && \
rm -rf /var/cache/yum

# Heasarc Ftools
ENV ASTROPFX /home/astrosoft
RUN mkdir -p $ASTROPFX
COPY setup_ftools.sh $HOME/setup_ftools.sh
RUN sh setup_ftools.sh && rm setup_ftools.sh

# Anaconda Fermitools, and other conda packages
ENV CONDAPFX /opt/anaconda
COPY setup_anaconda.sh $HOME/setup_anaconda.sh
RUN sh setup_anaconda.sh && rm setup_anaconda.sh

# Fermitools prefix
ENV FERMIPFX $CONDAPFX/envs/fermi
# ENV LD_LIBRARY_PATH $FERMIPFX/lib

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

# RUN /opt/anaconda/bin/conda install --yes --name fermi -c conda-forge fermipy \
# && rm -rf /opt/anaconda/pkgs/*

# RUN chmod -R g+rwx /opt/anaconda
# RUN chmod -R g+rwx /home/astrosoft

# copy build products into new layer
FROM centos:6
MAINTAINER "Fermi LAT Collaboration"

VOLUME ["/data"]

CMD [ "/bin/bash" ]

RUN sed -i '/tsflags=nodocs/d' /etc/yum.conf && \
yum update -y && \
yum install -y \
  bzip2 \
  dejavu-lgc-sans-fonts \
  emacs \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  gedit \
  git \
  libXext \
  libXrender \
  libSM \
  libX11 \
  libXt \
  make \
  mesa-libGL \
  ncurses\
  patch \
  perl \
  readline\
  sudo \
  tar \
  vim \
  which \
  xorg-x11-apps \
&& \
yum clean all && \
rm -rf /var/cache/yum

COPY --from=builder --chown=root:wheel /opt/anaconda /opt/anaconda
COPY --from=builder --chown=root:wheel /home/astrosoft /home/astrosoft

RUN echo -e '%wheel        ALL=(ALL)       NOPASSWD: ALL\n\
fermi        ALL=NOPASSWD: ALL\n\
fermi ALL=NOPASSWD: /usr/bin/yum' >> /etc/sudoers

COPY entrypoint /opt/docker/bin/entrypoint

ENTRYPOINT ["/opt/anaconda/bin/tini", "--", "/opt/docker/bin/entrypoint"]
