FROM debian:8
ENV packages="libssl-dev \
            git \
            xz-utils \
            autoconf \
            automake \
            gcc \
            libopus-dev \
            libmp3lame-dev \
            libvorbis-dev \
            libtheora-dev \
            build-essential \
            libtool \
            make \
            nasm \
            zlib1g-dev \
            tar \
            curl \
            yasm"
ENV PATH /usr/bin/:$PATH

RUN apt-get update && \
    apt-get install -y $packages

# build ffmpeg
ARG FFMPEG_VERSION="snapshot"
	# monitor releases at https://github.com/FFmpeg/FFmpeg/releases
ARG FDKAAC_VERSION="0.1.4"
	# monitor releases at https://github.com/mstorsjo/fdk-aac/releases
ARG	FAAC_VERSION="1.28"
ENV	SRC             	/usr/local
ENV	LD_LIBRARY_PATH 	${SRC}/lib
ENV	PKG_CONFIG_PATH 	${SRC}/lib/pkgconfig
# Compatible and tested: --enable-libfaac --enable-libmp3lame --enable-version3 --enable-gpl --enable-nonfree --enable-libfdk_aac
ARG ADDITIONAL_FLAGS=""

RUN echo Buildflags: ${ADDITIONAL_FLAGS}

COPY build.sh /build.sh
RUN  chmod +x /build.sh && bash /build.sh

#RUN	apt-get purge -y $packages
RUN apt-get clean
RUN apt-get autoclean

VOLUME /usr/local/bin/ffmpeg
VOLUME /usr/local/bin/ffprobe

CMD /bin/bash -c "tail -f /dev/null ; ffmpeg -version ; ffprobe -version"
