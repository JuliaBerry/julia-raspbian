JULIA_VER:=0.6.2
EMAIL:=juliapro@juliacomputing.com

.PHONY: clean all install-deps

all: julia-$(JULIA_VER).deb

# install necessary dependencies
install-deps:
	sudo apt-get install llvm-3.9-dev libpcre2-dev libdsfmt-dev libopenblas-dev libfftw3-dev libgmp3-dev libmpfr-dev libarpack2-dev libopenspecfun-dev libsuitesparse-dev libssh2-1-dev libcurl4-openssl-dev libssl-dev zlib1g-dev devscripts alien build-essential m4 gfortran cmake patchelf

# 1. download source
source/julia-$(JULIA_VER).tar.gz :
	mkdir -p source
	wget -c -P source https://github.com/JuliaLang/julia/releases/download/v$(JULIA_VER)/julia-$(JULIA_VER).tar.gz

# 2. setup build dir
build/Make.user : source/julia-$(JULIA_VER).tar.gz
	rm -fr build
	mkdir build
	tar -zxvf $< -C build --strip-components=1
	cp -f Make.user build

# 3. build Julia binary-dist
build/julia-$(JULIA_VER)-Linux-arm.tar.gz : build/Make.user
	$(MAKE) -C build -j1 binary-dist

# 4. generate debian package structure
julia-$(JULIA_VER) :  build/julia-$(JULIA_VER)-Linux-arm.tar.gz
	fakeroot alien -d --generate $<
	mv $@/julia-$(JULIA_VER) $@/usr
	mv $@/usr/LICENSE.md $@/usr/share/doc/julia/
	rm -f $@/usr/lib/julia/libstdc++.so*
	rm -f $@/usr/bin/*-debug* lib/*-debug* lib/julia/*-debug*
	rm -f $@/usr/lib/julia/libccalltest*
	cp -f control $@/debian/

# 5. build .deb
julia-$(JULIA_VER).deb: julia-$(JULIA_VER)
	cd julia-$(JULIA_VER) && debuild --no-sign

clean-build:
	rm -rf build
clean: clean-build clean-repack
