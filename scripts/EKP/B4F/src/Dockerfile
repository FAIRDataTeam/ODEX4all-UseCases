FROM ubuntu:16.04

MAINTAINER Arnold Kuzniar <a.kuzniar@esciencecenter.nl>

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    automake \
    gperf \
    gawk \
    libtool \
    flex \
    bison \
    libssl-dev \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

ARG VOS_VER=stable/7
ARG VOS_PREFIX=/usr/local/virtuoso-opensource

WORKDIR /tmp

RUN git clone -b $VOS_VER https://github.com/openlink/virtuoso-opensource.git

WORKDIR virtuoso-opensource

ENV CFLAGS="-O2 -m64"

RUN ./autogen.sh && ./configure --prefix=$VOS_PREFIX \
    --enable-conductor-vad \
    --enable-rdb2rdf-vad \
    --enable-rdfmappers-vad \
    --enable-fct-vad \
    && make -j $(nproc) && make install

ENV PATH=${VOS_PREFIX}/bin:$PATH

WORKDIR /tmp

RUN rm -fr $(basename $VOS_PREFIX)

VOLUME /tmp/data

WORKDIR ${VOS_PREFIX}/var/lib/virtuoso/db

RUN sed -i '/DirsAllowed/ s:$:,/tmp/data:' virtuoso.ini

EXPOSE 8890
EXPOSE 1111

CMD ["virtuoso-t", "+wait", "+foreground", "+configfile", "virtuoso.ini"]
