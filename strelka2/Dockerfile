FROM ubuntu:18.04

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/argo-somatic-variant-calling

ARG PYTHON_VERSION=2.7.5

# Install dependencies
# PIP - openssl version > 1.1 may be an issue (try older ubuntu images)
RUN apt-get update \
  && apt-get install -y wget gcc make openssl libffi-dev libgdbm-dev libsqlite3-dev libssl-dev zlib1g-dev \
  && apt-get clean

WORKDIR /tmp/

# Build Python from source
RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz \
  && tar --extract -f Python-$PYTHON_VERSION.tgz \
  && cd ./Python-$PYTHON_VERSION/ \
  && ./configure --enable-optimizations --prefix=/usr/local \
  && make && make install \
  && cd ../ \
  && rm -r ./Python-$PYTHON_VERSION*

RUN apt-get install -y cmake g++ libboost-all-dev

ARG STRELKA_VERSION=2.9.10

RUN wget https://github.com/Illumina/strelka/releases/download/v${STRELKA_VERSION}/strelka-${STRELKA_VERSION}.release_src.tar.bz2 \
  && tar -xjf strelka-${STRELKA_VERSION}.release_src.tar.bz2 \
  && mkdir build && cd build \
  && ../strelka-${STRELKA_VERSION}.release_src/configure --jobs=4 --prefix=/opt/strelka2 \
  && make -j4 install \
  && rm -fr /tmp/*


ENV PATH="/tools:/opt/strelka2/bin:${PATH}"

COPY *.py /tools/

RUN groupadd -g 1000 ubuntu && \
    useradd -l -u 1000 -g ubuntu ubuntu && \
    install -d -m 0755 -o ubuntu -g ubuntu /home/ubuntu

USER ubuntu

WORKDIR /home/ubuntu

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
