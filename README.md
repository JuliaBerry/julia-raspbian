# julia-raspbian

A set of build scripts to build a Julia deb for Raspbian

The following packages need to be installed before building

`sudo apt-get install llvm-3.9-dev libpcre2-dev libdsfmt-dev libopenblas-dev libfftw3-dev libgmp3-dev libmpfr-dev libarpack2-dev libopenspecfun-dev libgit2-dev libssh2-1-dev libcurl4-openssl-dev libssl-dev zlib1g-dev devscripts alien build-essential m4 gfortran cmake patchelf`

Run ./deb.sh to build the debian package. If it completes with an
error about debsign failing, that is ok. The debs will be in the
julia/ folder.