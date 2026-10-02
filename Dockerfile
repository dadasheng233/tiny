FROM docker.m.daocloud.io/library/ubuntu:24.04

ARG BINUTILS_VERSION=2.44
ARG GCC_VERSION=14.2.0
ENV PREFIX=/opt/cross
ENV TARGET=i686-elf
ENV PATH=/opt/cross/bin:$PATH

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential bison flex libgmp-dev libmpc-dev libmpfr-dev texinfo wget ca-certificates \
    grub-pc-bin grub-common xorriso qemu-system-x86 make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/src
RUN wget -q https://mirrors.sjtug.sjtu.edu.cn/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz \
    && wget -q https://mirrors.sjtug.sjtu.edu.cn/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz \
    && tar -xf binutils-${BINUTILS_VERSION}.tar.xz \
    && tar -xf gcc-${GCC_VERSION}.tar.xz

RUN mkdir /tmp/build-binutils && cd /tmp/build-binutils \
    && ../src/binutils-${BINUTILS_VERSION}/configure --target=${TARGET} --prefix=${PREFIX} --with-sysroot --disable-nls --disable-werror \
    && make -j"$(nproc)" \
    && make install

RUN cd /tmp/src/gcc-${GCC_VERSION} \
    && ./contrib/download_prerequisites \
    && mkdir /tmp/build-gcc && cd /tmp/build-gcc \
    && ../src/gcc-${GCC_VERSION}/configure --target=${TARGET} --prefix=${PREFIX} --disable-nls --enable-languages=c --without-headers \
    && make -j"$(nproc)" all-gcc all-target-libgcc \
    && make install-gcc install-target-libgcc

WORKDIR /workspace
ENTRYPOINT ["make"]
