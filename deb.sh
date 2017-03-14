 #!/bin/bash
set -e

JULIA_VER=0.5.1

#git clone https://github.com/JuliaLang/julia.git

wget https://github.com/JuliaLang/julia/releases/download/v$JULIA_VER/julia-$JULIA_VER.tar.gz
mkdir julia
tar -zxvf julia-$JULIA_VER.tar.gz -C julia --strip-components=1
export OPENBLAS_NUM_THREADS=1

cp Make.user julia

cd julia && make -j4 binary-dist

JULIA_COMMIT=`ls julia*-Linux-*.tar.gz | cut -b 7-16`
#JULIA_VER=`./bin/julia -version | cut -b 15-19`


rm -fr julia-$JULIA_VER julia_*
tar zxf julia-$JULIA_VER-Linux-*.tar.gz
cd julia-$JULIA_VER
mv LICENSE.md share/doc/julia/LICENSE.md
rm -f lib/julia/libpcre2-posix.so*
rm -f lib/julia/libstdc++.so*
rm -f bin/*-debug* lib/*-debug* lib/julia/*-debug*
rm -fr libexec
rm -f lib/julia/libccalltest*
gcc -shared /usr/lib/*-linux-*/libsuitesparseconfig.a -o lib/julia/libsuitesparseconfig.so
tar cf ../julia-$JULIA_VER.tar *
cd ..
rm -fr julia-$JULIA_VER
fakeroot alien -d --generate julia-$JULIA_VER.tar
cp -f ../control julia-$JULIA_VER/debian
cd julia-$JULIA_VER
debuild --no-lintian
