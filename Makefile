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
	wget -c -P source https://github.com/JuliaLang/julia/releases/download/v$(JULIA_VER)/$@

# 2. setup build dir
build/Make.user : source/julia-$(JULIA_VER).tar.gz
	rm -fr build
	mkdir build
	tar -zxvf $< -C build --strip-components=1
	cp -f Make.user build

# 3. build Julia binary-dist
build/julia-$(JULIA_VER)-Linux-arm.tar.gz : build/Make.user
	$(MAKE) -C build -j1 binary-dist

# 4. repack into debian structure, removing unnecessary files
repack/julia-$(JULIA_VER).tar : build/julia-$(JULIA_VER)-Linux-arm.tar.gz
	rm -fr repack
	mkdir repack
	tar zxf $< -C repack --strip-components=1
	mv repack/LICENSE.md repack/share/doc/julia/
	rm -f repacklib/julia/libpcre2-posix.so*
	rm -f repack/lib/julia/libstdc++.so*
	rm -f repack/bin/*-debug* lib/*-debug* lib/julia/*-debug*
	rm -fr repack/libexec
	rm -f repack/lib/julia/libccalltest*
	mkdir repack/usr
	mv repack/bin repack/include repack/lib repack/usr/
	tar cvf $@ repack/*

# 5. build .deb
julia-$(JULIA_VER).deb: repack/julia-$(JULIA_VER).tar
	rm -fr julia-$(JULIA_VER)
	fakeroot alien -d --generate $<
	cp -f control julia-$(JULIA_VER)/debian/
	cd julia-$(JULIA_VER) && debuild --no-lintian

clean-build:
	rm -rf build
clean-repack:
	rm -rf repack
clean: clean-build clean-repack
