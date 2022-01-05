FROM charesgregory/dlang-ldc-static

RUN apk add --update --no-cache \
    autoconf automake make cmake \
    zlib zlib-dev zlib-static \
    xz xz-dev \
    bzip2 bzip2-dev bzip2-static 

WORKDIR /home/

# apparently musl-c allocation is bad with multiple threads
# suggestion was to use mimalloc
RUN git clone https://github.com/microsoft/mimalloc.git \
    && cd mimalloc \
    && git checkout v2.0.3 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make -j 8 \
    && make install \
    && cd /home/ \
    && rm -r mimalloc

# build libdeflate
# note we are using the same libdeflate that rust-htslib is using
ENV DEFLATE_VER=1.8
RUN wget https://github.com/ebiggers/libdeflate/archive/refs/tags/v$DEFLATE_VER.tar.gz \
    && tar -xf v$DEFLATE_VER.tar.gz \
    && cd libdeflate-$DEFLATE_VER \
    && make install -j 8 \
    && cd /home/ \
    && rm -r libdeflate-$DEFLATE_VER

# build openssl
ENV SSL_VER=3.0.0
RUN wget https://www.openssl.org/source/openssl-$SSL_VER.tar.gz \
    && tar -xf openssl-$SSL_VER.tar.gz \
    && cd openssl-$SSL_VER \
    && ./Configure --prefix=/usr/local linux-x86_64 no-async no-engine -DOPENSSL_NO_SECURE_MEMORY \
    && make -j 8 \
    && make install_sw -j 8 \
    && cd /home/ \
    && rm -r openssl-$SSL_VER

# build libssh2
ENV SSH2_VER=1.10.0
RUN wget https://github.com/libssh2/libssh2/releases/download/libssh2-$SSH2_VER/libssh2-$SSH2_VER.tar.gz \
    && tar -xf libssh2-$SSH2_VER.tar.gz \
    && cd libssh2-$SSH2_VER \
    && CFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib64" ./configure --prefix=/usr/local \
    && make -j 8 \
    && make install \
    && cd /home/ \
    && rm -r libssh2-$SSH2_VER

# build libcurl
ENV CURL_VER=7.80.0
RUN wget https://github.com/curl/curl/releases/download/curl-7_80_0/curl-$CURL_VER.tar.gz \
    && tar -xf curl-$CURL_VER.tar.gz \
    && cd curl-$CURL_VER \
    && ./configure --with-libssh2 --with-ssl --prefix=/usr/local --enable-get-easy-options --enable-ftp \
    && make -j 8 \
    && make install -j 8 \
    && cd /home/ \
    && rm -r curl-$CURL_VER

# build htslib
ENV HTS_VER=1.14
RUN wget https://github.com/samtools/htslib/releases/download/$HTS_VER/htslib-$HTS_VER.tar.bz2 \
    && tar xf htslib-$HTS_VER.tar.bz2 \
    && cd htslib-$HTS_VER \
    && ./configure \
    && make -j 8 \
    && make install \
    && cd /home/ \
    && rm -r htslib-$HTS_VER

