FROM debian:bullseye AS rt-kernel-build

# Install some tools and compilers + clean up
RUN apt-get update &&\
    apt-get install -y build-essential git wget gcc make &&\
    apt-get install -y python3 python3-pip &&\
    apt-get install -y bc bison flex libssl-dev &&\
    apt-get install -y libc6-dev libncurses5-dev libelf-dev &&\
    apt-get install -y kmod rsync dwarves cpio liblz4-tool &&\
    apt-get clean autoclean &&\
    apt-get autoremove -y &&\
    rm -rf /var/lib/apt/lists/*

ARG APP_NAME=RtKernel
ARG KERNEL_VER=5.16
ARG KERNEL_BUILD=.2
ARG RTPATCH_VER=5.16.2-rt19
ARG KERNEL_NAME=linux-${KERNEL_VER}${KERNEL_BUILD}
ARG KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v5.x/${KERNEL_NAME}.tar.gz
ARG RTPATCH_URL=https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_VER}/patch-${RTPATCH_VER}.patch.gz
ARG DEBIAN_CERT=https://salsa.debian.org/kernel-team/linux/-/raw/master/debian/certs/debian-uefi-certs.pem

CMD ["/bin/bash"]

WORKDIR /app/${APP_NAME}

ADD ${KERNEL_URL}               /app/${APP_NAME}/${KERNEL_NAME}.tar.gz
ADD ${RTPATCH_URL}              /app/${APP_NAME}/rt-patch.gz
ADD ${DEBIAN_CERT}              /app/${APP_NAME}/${KERNEL_NAME}/debian/certs/

RUN tar xf ${KERNEL_NAME}.tar.gz

WORKDIR /app/${APP_NAME}/${KERNEL_NAME}

RUN zcat ../rt-patch.gz | patch -p1

ENV ARCH=x86_64
ENV CROSS_COMPILE=

ADD azure-rt.config              .config

RUN make -j$(grep -c processor /proc/cpuinfo) bindeb-pkg LOCALVERSION=-custom
#RUN make bindeb-pkg LOCALVERSION=-custom

RUN mkdir -p /app/dist; \
    cp -f /app/${APP_NAME}/*.deb /app/dist
