#!/bin/bash

mkdir -p "/ffmpeg/bin"
CORES=$(cat /proc/cpuinfo | grep processor | wc -l)
echo -e "------\n\n\nDetected ${CORES} cores/CPUs, will try to run make with '-j${CORES}'.\n\n\n"

# FAAC if enabled
# This combines faac + http://stackoverflow.com/a/4320377
if [[ "-${ADDITIONAL_FLAGS}" =~ .*libfaac.* ]]; then
    DIR=$(mktemp -d)
    cd ${DIR}
    curl -L -Os http://downloads.sourceforge.net/faac/faac-${FAAC_VERSION}.tar.gz
    tar xzvf faac-${FAAC_VERSION}.tar.gz
    cd faac-${FAAC_VERSION}
    sed -i '126d' common/mp4v2/mpeg4ip.h
    ./bootstrap
    ./configure --prefix="${SRC}" --bindir="${SRC}/bin"
    make -j${CORES}
    make install
    rm -rf ${DIR}
else
    echo -e "------\n\n\nFAAC not enabled, will not build FAAC!\n\n\n"
fi


# FDK_AAC if enabled
if [[ "-${ADDITIONAL_FLAGS}" =~ .*libfdk_aac.* ]]; then
    DIR=$(mktemp -d)
    cd ${DIR}
    curl -s https://codeload.github.com/mstorsjo/fdk-aac/tar.gz/v${FDKAAC_VERSION} | tar zxvf -
    cd fdk-aac-${FDKAAC_VERSION}
    autoreconf -fiv
    ./configure --prefix="${SRC}" --disable-shared
    make -j${CORES}
    make install
    make distclean
    rm -rf ${DIR}
else
    echo -e "------\n\n\nFDK_AAC not enabled, will not build FDK_AAC!\n\n\n"
fi

# FFMPEG
#--enable-libopus is buggy
DIR=$(mktemp -d)
cd ${DIR}
curl -Os http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2
tar jxvf ffmpeg-${FFMPEG_VERSION}.tar.bz2
rm -f ffmpeg-${FFMPEG_VERSION}.tar.bz2
ls -lsa
cd ffmpeg*
./configure \
    --pkg-config-flags="--static" \
    --prefix="${SRC}" \
    --extra-cflags="-I${SRC}/include" \
    --extra-ldflags="-L${SRC}/lib" \
    --bindir="/ffmpeg/bin" \
    --extra-libs=-static \
    --enable-static \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-postproc \
    --enable-avresample \
    --disable-debug \
    --enable-small \
    ${ADDITIONAL_FLAGS}
    --disable-ffplay \
    --disable-ffserver \
    --disable-shared
make -j${CORES}
make install
make distclean
hash -r
rm -rf ${DIR}
