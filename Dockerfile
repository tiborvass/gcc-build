# syntax = tonistiigi/dockerfile:runmount20180618 

# i386-extall-20180811
# syntax = tiborvass/dockerfile:i386-extall-20180811

FROM debian:jessie AS base
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked apt-get update && apt-get install -y --no-install-recommends ca-certificates curl tar unzip

FROM base AS src
ARG VERSION=3_3_4
RUN curl -O https://github.com/gcc-mirror/gcc/archive/gcc-${VERSION}-release.zip && unzip gcc-${VERSION}-release.zip && rm gcc-*.zip && mv gcc-* /gcc
#git clone -b gcc-$VERSION-branch --depth 1 https://github.com/gcc-mirror/gcc /gcc
RUN cd / && curl -O http://ftp.gnu.org/gnu/texinfo/texinfo-4.13.tar.gz && gzip -dc < texinfo-4.13.tar.gz | tar -xf - && cd texinfo-4.13
WORKDIR /gcc

FROM src AS gcc-dev
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked apt-get install -y --no-install-recommends make build-essential flex bison autoconf automake libreadline-dev
#ENV LIBRARY_PATH=/usr/lib/i386-linux-gnu:$LIBRARY_PATH
#RUN ln -s /usr/include/asm-generic /usr/include/asm

#FROM gcc-dev as tmp
#RUN --mount=type=cache,target=/gcc/build,sharing=locked cd /gcc/build && make clean maintainer-clean

FROM gcc-dev as gcc
RUN cd /texinfo-4.13 && ./configure && make && make install
#COPY --from=tmp /bin/true /tmp/
RUN --mount=type=cache,target=/gcc/build,sharing=locked cd /gcc/build && MISSING=texinfo ../configure --prefix=/gcc/install --enable-bootstrap --disable-shared --disable-multilib --enable-languages=c && make && make install

FROM alpine
COPY --from=src /gcc /gcc
COPY --from=gcc /gcc/install/* /usr/

