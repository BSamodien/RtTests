# https://github.com/Pro/raspi-toolchain
FROM debian:bullseye AS pi-build

# Install some tools and compilers + clean up
RUN apt-get update \
    && apt-get install -y git wget gcc make \
    && apt-get install -y gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu \
    && apt-get install -y python3 python3-pip \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install cmake

ENV CROSS_COMPILE ''
ENV APP_ROOT /app

WORKDIR ${APP_ROOT}

CMD ["/bin/bash"]

FROM pi-build AS rt-test

ENV CROSS_COMPILE ''
ENV APP_ROOT      /app
ENV APP_NAME      RtTests
ENV APP_DIST      ${APP_ROOT}/dist

# Install some tools and compilers + clean up
RUN apt-get update \
    && apt-get install -y libnuma-dev python \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${APP_ROOT}

RUN git clone https://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git ${APP_NAME}

WORKDIR ${APP_ROOT}/${APP_NAME}

RUN git checkout stable/v1.0 \
    && make CC=${CROSS_COMPILE}gcc AR=${CROSS_COMPILE}ar all -j$(grep -c processor /proc/cpuinfo) \
    && make DESTDIR=${APP_ROOT}/${APP_NAME}/dist prefix= install \
    && mkdir -p ${APP_DIST} \
    && tar -C dist -zcf ${APP_DIST}/rt-tests.tar.gz . \
    && make distclean
