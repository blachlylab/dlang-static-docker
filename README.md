Build static D binaries with docker
============================

This repo provides dockerfiles to create docker images used for creating 
fully-static D program binaries. It serves as an example of how to compile static Dlang 
programs using alpine linux, `musl-c`, and the `ldc` compiler. It also 
serves as an example of how to configure github actions to build a docker image, 
push it to Dockerhub, and create a release draft that has the static binary
attached from the uploaded docker image. The created binary should work on 
any x86_64 linux distribution. 

The `dlang/ldc.dockerfile` provides a base environment that can be used to create
static dlang binaries. An example D program can be found here: `tests/test-app`.

### Shared Libraries
If your program requires other shared libraries you will have to manipulate the 
`dub.json` file further. The `dub.json` excerpt below example is taken from 
another D program, [fade](https://github.com/blachlylab/fade):

```json
    "configurations":[
		{
			"name":"shared",
			"targetType": "executable"
		},
		{
			"name":"static-alpine",
			"targetType": "executable",
			"dflags-ldc": [
				"-link-defaultlib-shared=false",
				"-static",
				"--linker=gold",
				"-L-lz",
				"-L-lbz2",
				"-L-ldeflate",
				"-L-llzma",
				"-L-lcurl", 
				"-L-lssl", 
				"-L-lssh2", 
				"-L-lcrypto"
			],
			"sourceFiles": ["/usr/local/lib/mimalloc-2.0/mimalloc.o"]
		}
	]
```
The `dflags` must be appended to include `"-L-lcurl"` lines for neccessary libraries,
and these libraries will need to be present in the docker image in both shared and static
library forms. For example, many libraries in the `htslib/Dockerfile` image had to be compiled
from source:
```dockerfile
# compiling libdeflate
RUN wget https://github.com/ebiggers/libdeflate/archive/refs/tags/v$DEFLATE_VER.tar.gz \
    && tar -xf v$DEFLATE_VER.tar.gz \
    && cd libdeflate-$DEFLATE_VER \
    && make install -j 8 \
    && cd /home/ \
    && rm -r libdeflate-$DEFLATE_VER
```
Though if the alpine repositories have it in both static and shared forms you may be able to 
avoid compiling them:
```dockerfile

```
These libraries also must be installed into locations on the LD_LIBRARY_PATH and LIBRARY_PATH or 
those environment variables must be altered. These are defined in our images as such:
```dockerfile
ENV LD_LIBRARY_PATH="/lib:/usr/local/lib:/usr/local/lib64:/usr/lib:$LD_LIBRARY_PATH"
ENV LIBRARY_PATH="$LD_LIBRARY_PATH"
```

### Mimalloc
Since many of our programs that rely on htslib are multi-threaded, we have also included this line:
```json
"sourceFiles": ["/usr/local/lib/mimalloc-2.0/mimalloc.o"]
```
`musl-c`'s allocation performance is poor compared to mimalloc in multi-threaded situations:
https://www.linkedin.com/pulse/testing-alternative-c-memory-allocators-pt-2-musl-mystery-gomes.
Our `htslib` image includes a compiled version of `mimalloc`, including the prior line in our `dub.json`
ensures that `mimalloc` is used for all allocation across our binary, even for libraries that weren't 
compiled with `mimalloc`.

### Docker and Github Actions

If your docker image is uploaded to Dockerhub, you can use the github actions `.github/workflows/build.yml` 
in this repo to have your docker image built and uploaded to Dockerhub via github actions. You will have to 
set up a dockerhub API key. The github actions `.github/workflows/release.yml` can pull a docker image from 
Dockerhub, extract your static binary from it, and create a release draft with the binary attached, just 
look at our `v0.0.1` [release](https://github.com/blachlylab/dlang-static-docker/releases/tag/v0.0.1).