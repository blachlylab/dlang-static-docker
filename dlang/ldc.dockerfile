FROM alpine

RUN apk add --update --no-cache \
    wget gcc g++ perl git \
    musl musl-dev \
    ldc ldc-static dub \
    binutils-gold \
    llvm-libunwind-static

ENV LD_LIBRARY_PATH="/lib:/usr/local/lib:/usr/local/lib64:/usr/lib:$LD_LIBRARY_PATH"
ENV LIBRARY_PATH="$LD_LIBRARY_PATH"