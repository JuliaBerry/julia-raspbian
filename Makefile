JULIA_VER:=0.6.2
EMAIL:=juliapro@juliacomputing.com

.PHONY: clean all install-deps

all: julia-$(JULIA_VER).tar
	rm -fr julia-$(JULIA_VER)
	fakeroot alien -d --generate julia-$(JULIA_VER).tar
	cp -f ../control julia-$(JULIA_VER)/debian
	cd julia-$(JULIA_VER)
	debuild --no-lintian

install-deps:
	sudo apt-get install llvm-3.9-dev libpcre2-dev libdsfmt-dev libopenblas-dev libfftw3-dev libgmp3-dev libmpfr-dev libarpack2-dev libopenspecfun-dev libsuitesparse-dev libssh2-1-dev libcurl4-openssl-dev libssl-dev zlib1g-dev devscripts alien build-essential m4 gfortran cmake patchelf


julia/julia-$(JULIA_VER)-Linux-arm.tar.gz :
	wget -c https://github.com/JuliaLang/julia/releases/download/v$(JULIA_VER)/julia-$(JULIA_VER).tar.gz
	mkdir -p julia/lib/julia
	tar -zxvf julia-$(JULIA_VER).tar.gz -C julia --strip-components=1
	cp -f Make.user julia
	$(MAKE) -C julia -j1 binary-dist

julia-$(JULIA_VER).tar : julia/julia-$(JULIA_VER)-Linux-arm.tar.gz
	rm -fr julia/julia-$(JULIA_VER) julia_*
	tar zxf julia/julia-$(JULIA_VER)-Linux-arm.tar.gz
	mv julia-$(JULIA_VER)/LICENSE.md julia-$(JULIA_VER)/share/doc/julia/LICENSE.md
	rm -f julia-$(JULIA_VER)/lib/julia/libpcre2-posix.so*
	rm -f julia-$(JULIA_VER)/lib/julia/libstdc++.so*
	rm -f julia-$(JULIA_VER)/bin/*-debug* lib/*-debug* lib/julia/*-debug*
	rm -fr julia-$(JULIA_VER)/libexec
	rm -f julia-$(JULIA_VER)/lib/julia/libccalltest*
	mkdir julia-$(JULIA_VER)/usr
	mv julia-$(JULIA_VER)/bin julia-$(JULIA_VER)/usr
	mv julia-$(JULIA_VER)/include julia-$(JULIA_VER)/usr
	mv julia-$(JULIA_VER)/lib julia-$(JULIA_VER)/usr
	mv julia-$(JULIA_VER)/share julia-$(JULIA_VER)/usr
	tar cvf julia-$(JULIA_VER).tar julia-$(JULIA_VER)/*
	rm -fr julia-$(JULIA_VER)
