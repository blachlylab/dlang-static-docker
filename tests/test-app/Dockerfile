FROM blachlylab/dlang-ldc-static

ADD . /home/test-app
WORKDIR /home/test-app
RUN dub build -c static-alpine
RUN ./test