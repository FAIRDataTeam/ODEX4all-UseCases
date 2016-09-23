FROM ubuntu:16.04
MAINTAINER Arnold Kuzniar <a.kuzniar@esciencecenter.nl>

RUN apt-get update -y && apt-get install -y \
    autoconf \
    automake \
    make \
    m4 \
    libtool \
    flex \
    bison \
    gperf \
    gawk \
    git \
    openssl \
    libssl-dev \
    net-tools \
    vim \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN git clone -b stable/7 https://github.com/openlink/virtuoso-opensource.git

WORKDIR virtuoso-opensource
ENV CFLAGS="-O2 -m64"
RUN ./autogen.sh && ./configure --prefix=/usr/local/virtuoso-opensource \
    --enable-conductor-vad \
    --enable-rdb2rdf-vad \
    --enable-rdfmappers-vad \
    --enable-fct-vad \
    && make && make install
ENV PATH=/usr/local/virtuoso-opensource/bin:$PATH

VOLUME /tmp/virtuoso-data
RUN sed -i '/DirsAllowed/ s:$:,/tmp/virtuoso-data:' /usr/local/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini

EXPOSE 8890
EXPOSE 1111

CMD ["virtuoso-t", "+wait", "+foreground", "+configfile", "/usr/local/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini"]


