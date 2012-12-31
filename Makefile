# GNU Make 3.82 won't build EGLIBC. Use a slightly older one, e.g. 3.81

PKGCONF           := rpi
BUGURL            :=

WGET              := wget --progress=dot

GMP_VER           := gmp-5.1.0
GMP_URL           := ftp://ftp.gmplib.org/pub/$(GMP_VER)/$(GMP_VER).tar.bz2
GMP_BZ2           := downloaded/$(GMP_VER).tar.bz2
GMP_DIR           := src/$(GMP_VER)

MPFR_VER          := mpfr-3.1.1
MPFR_URL          := http://www.mpfr.org/mpfr-current/$(MPFR_VER).tar.bz2
MPFR_BZ2          := downloaded/$(MPFR_VER).tar.bz2
MPFR_DIR          := src/$(MPFR_VER)

MPC_VER           := mpc-1.0.1
MPC_URL           := http://www.multiprecision.org/mpc/download/$(MPC_VER).tar.gz
MPC_GZ            := downloaded/$(MPC_VER).tar.gz
MPC_DIR           := src/$(MPC_VER)

BINUTILS_VER      := binutils-2.22
BINUTILS_URL      := http://ftp.gnu.org/gnu/binutils/$(BINUTILS_VER).tar.bz2
BINUTILS_BZ2      := downloaded/$(BINUTILS_VER).tar.bz2
BINUTILS_DIR      := src/$(BINUTILS_VER)

GCC_VER           := gcc-4.7.2
GCC_URL           := http://archive.raspbian.org/raspbian/pool/main/g/gcc-4.7/gcc-4.7_4.7.2.orig.tar.gz
GCC_GZ            := downloaded/gcc-4.7_4.7.2.orig.tar.gz
GCC_DIR           := $(shell pwd)/src/gcc-4.7.2

LINUX_VER         := linux-3.2.27
LINUX_URL         := http://www.kernel.org/pub/linux/kernel/v3.x/$(LINUX_VER).tar.bz2
LINUX_BZ2         := downloaded/$(LINUX_VER).tar.bz2
LINUX_DIR         := $(shell pwd)/src/$(LINUX_VER)

EGLIBC_VER        := eglibc-2.13
EGLIBC_URL        := http://archive.raspbian.org/raspbian/pool/main/e/eglibc/eglibc_2.13.orig.tar.gz
EGLIBC_GZ         := downloaded/$(EGLIBC_VER).tar.gz
EGLIBC_DIR        := src/$(EGLIBC_VER)

BUILD    := $(shell gcc -v 2>&1 | grep '\-\-build=' | sed -e 's/^.*--build=//' | sed -e 's/\s.*$$//')
TARGET   := arm-linux-gnueabihf
INST     := $(shell pwd)/inst
TEMPINST := $(shell pwd)/tempinst

announce = ( tput bold; tput setf 2; echo Starting ${@:stamps/%=%}; tput sgr0 ) >/dev/stderr
touch = mkdir -p stamps && touch $@ && ( tput bold; tput setf 6; echo Done ${@:stamps/%=%}; tput sgr0 ) >/dev/stderr

all: stamps/phobos_installed
.PHONY: all

# download

$(GMP_BZ2):
	@$(announce)
	@mkdir -p $(dir $@) && $(WGET) $(GMP_URL) -O $@ 2>$@.wget.log

$(MPFR_BZ2):
	@$(announce)
	@mkdir -p $(dir $@) && $(WGET) $(MPFR_URL) -O $@ 2>$@.wget.log

$(MPC_GZ):
	@$(announce)
	@mkdir -p $(dir $@) && $(WGET) $(MPC_URL) -O $@ 2>$@.wget.log

$(BINUTILS_BZ2):
	@$(announce)
	@mkdir -p $(dir $@) && $(WGET) $(BINUTILS_URL) -O $@ 2>$@.wget.log

$(GCC_GZ):
	@$(announce)
	@mkdir -p $(dir $@) && $(WGET) $(GCC_URL) -O $@ 2>$@.wget.log

$(LINUX_BZ2):
	@$(announce)
	@mkdir -p $(dir $@) && $(WGET) $(LINUX_URL) -O $@ 2>$@.wget.log

$(EGLIBC_GZ):
	@$(announce)
	@mkdir -p $(dir $@) && $(WGET) $(EGLIBC_URL) -O $@ 2>$@.wget.log

# gmp

stamps/unpack_gmp: $(GMP_BZ2)
	@$(announce) && \
	( mkdir -p src && cd src && rm -rf "$(GMP_VER)" && tar jxf ../$(GMP_BZ2) ) \
	&& $(touch)

stamps/gmp_configured: stamps/unpack_gmp
	@$(announce) && \
	( mkdir -p build/gmp && cd build/gmp && \
		export LD_LIBRARY_PATH=$(TEMPINST)/lib:"$$LD_LIBRARY_PATH" && \
		../../$(GMP_DIR)/configure \
		--build=$(BUILD) \
		--host=$(BUILD) \
		--prefix=$(TEMPINST) \
		--libdir=$(TEMPINST)/lib \
		--disable-shared \
		--enable-cxx ) \
	&& $(touch)

stamps/gmp_built: stamps/gmp_configured
	@$(announce) && \
	( cd build/gmp && $(MAKE) ) \
	&& $(touch)

stamps/gmp_installed: stamps/gmp_built
	@$(announce) && \
	( cd build/gmp && $(MAKE) install ) \
	&& $(touch)

stamps/gmp_checked: stamps/gmp_installed
	@$(announce) && \
	( cd build/gmp && $(MAKE) CFLAGS='-O2 -g' check ) \
	&& $(touch)

# mpfr

stamps/unpack_mpfr: $(MPFR_BZ2)
	@$(announce) && \
	( mkdir -p src && cd src && rm -rf "$(MPFR_VER)" && tar jxf ../$(MPFR_BZ2) ) \
	&& $(touch)

stamps/mpfr_configured: stamps/unpack_mpfr stamps/gmp_checked
	@$(announce) && \
	( mkdir -p build/mpfr && cd build/mpfr && ../../$(MPFR_DIR)/configure \
		--build=$(BUILD) \
		--host=$(BUILD) \
		--prefix=$(TEMPINST) \
		--libdir=$(TEMPINST)/lib \
		--disable-shared \
		--with-gmp=$(TEMPINST) ) \
	&& $(touch)

stamps/mpfr_built: stamps/mpfr_configured
	@$(announce) && \
	( cd build/mpfr && $(MAKE) ) \
	&& $(touch)

stamps/mpfr_installed: stamps/mpfr_built
	@$(announce) && \
	( cd build/mpfr && $(MAKE) install ) \
	&& $(touch)

stamps/mpfr_checked: stamps/mpfr_installed
	@$(announce) && \
	( cd build/mpfr && $(MAKE) check ) \
	&& $(touch)

# mpc

stamps/unpack_mpc: $(MPC_GZ)
	@$(announce) && \
	( mkdir -p src && cd src && rm -rf "$(MPC_VER)" && tar zxf ../$(MPC_GZ) ) \
	&& $(touch)

stamps/mpc_configured: stamps/unpack_mpc stamps/gmp_checked stamps/mpfr_checked
	@$(announce) && \
	( mkdir -p build/mpc && cd build/mpc && ../../$(MPC_DIR)/configure \
		--build=$(BUILD) \
		--host=$(BUILD) \
		--prefix=$(TEMPINST) \
		--libdir=$(TEMPINST)/lib \
		--disable-shared \
		--with-gmp=$(TEMPINST) \
		--with-mpfr-lib=$(TEMPINST)/lib \
		--with-mpfr-include=$(TEMPINST)/include ) \
	&& $(touch)

stamps/mpc_built: stamps/mpc_configured
	@$(announce) && \
	( cd build/mpc && $(MAKE) ) \
	&& $(touch)

stamps/mpc_installed: stamps/mpc_built
	@$(announce) && \
	( cd build/mpc && $(MAKE) install ) \
	&& $(touch)

stamps/mpc_checked: stamps/mpc_installed
	@$(announce) && \
	( cd build/mpc && $(MAKE) check ) \
	&& $(touch)

# binutils

stamps/unpack_binutils: $(BINUTILS_BZ2)
	@$(announce) && \
	( mkdir -p src && cd src && rm -rf "$(BINUTILS_DIR)" && tar jxf ../$(BINUTILS_BZ2) ) \
	&& $(touch)

stamps/binutils_configured: stamps/unpack_binutils stamps/gmp_checked stamps/mpfr_checked stamps/mpc_checked
	@$(announce) && \
	( mkdir -p build/binutils && cd build/binutils && ../../$(BINUTILS_DIR)/configure \
		--build=$(BUILD) \
		--host=$(BUILD) \
		--target=$(TARGET) \
		--prefix="$(INST)" \
		--with-sysroot="$(INST)" \
		--disable-nls \
		--with-arch=armv6 \
		--with-pkgversion="$(PKGCONF)" \
		--with-bugurl="$(BTURL)" \
		--with-gmp-include="$(TEMPINST)"/include \
		--with-gmp-lib="$(TEMPINST)"/lib \
		--with-mpfr-include="$(TEMPINST)"/include \
		--with-mpfr-lib="$(TEMPINST)"/lib \
		--with-mpc-include="$(TEMPINST)"/include \
		--with-mpc-lib="$(TEMPINST)"/lib ) \
	&& $(touch)

stamps/binutils_built: stamps/binutils_configured
	@$(announce) && \
	( cd build/binutils && $(MAKE) ) \
	&& $(touch)

stamps/binutils_installed: stamps/binutils_built
	@$(announce) && \
	( cd build/binutils && $(MAKE) install ) \
	&& $(touch)

# gcc

stamps/unpack_gcc: $(GCC_GZ)
	@$(announce) && \
	( mkdir -p src && cd src && rm -rf "$(GCC_DIR)" && tar zxf ../$(GCC_GZ) && tar Jxf gcc-4.7-4.7.2.orig/gcc-4.7.2-dfsg.tar.xz ) \
	&& $(touch)

stamps/gcc_patched: stamps/unpack_gcc $(gcc_patch_files)
	@$(announce) && \
	( cd $(GCC_DIR) && export QUILT_PATCHES=../../debian/patches && quilt --quiltrc=/dev/null push -a ) \
	&& $(touch)

# gcc1

stamps/gcc1_configured: stamps/gcc_patched stamps/gmp_checked stamps/mpfr_checked stamps/mpc_checked stamps/binutils_installed
	@$(announce) && \
	( mkdir -p build/gcc1 && cd build/gcc1 && $(GCC_DIR)/configure \
		--build="$(BUILD)" \
		--host="$(BUILD)" \
		--target="$(TARGET)" \
		--prefix="$(INST)" \
		--with-arch=armv6 \
		--with-fpu=vfp \
		--with-float=hard \
		--disable-sjlj-exceptions \
		--enable-checking=release \
		--enable-linker-build-id \
		--enable-gnu-unique-object \
		--disable-nls \
		--enable-languages=c \
		--without-headers \
		--disable-shared \
		--disable-threads \
		--disable-multilib \
		--disable-decimal-float \
		--disable-libmudflap \
		--disable-libssp \
		--disable-libgomp \
		--without-ppl \
		--without-cloog \
		--with-gmp="$(TEMPINST)" \
		--with-mpfr="$(TEMPINST)" \
		--with-mpc="$(TEMPINST)" ) \
	&& $(touch)

stamps/gcc1_built: stamps/gcc1_configured
	@$(announce) && \
	( cd build/gcc1 && \
		$(MAKE) all-gcc ) \
	&& $(touch)

stamps/gcc1_installed: stamps/gcc1_built
	@$(announce) && \
	( cd build/gcc1 && $(MAKE) install-gcc ) \
	&& $(touch)

# linux headers

stamps/unpack_linux: $(LINUX_BZ2)
	@$(announce) && \
	( mkdir -p src && cd src && rm -rf "$(LINUX_DIR)" && tar jxf ../$(LINUX_BZ2) ) \
	&& $(touch)

stamps/linux_installed: stamps/unpack_linux stamps/gcc1_installed
	$(announce) && \
	( rm -rf build/linux && cp -al $(LINUX_DIR) build/linux && cd build/linux && \
		export TARGET=arm-linux-gnueabihf && \
		export PREFIX="$(INST)" && \
		export PATH="$$PATH:$$PREFIX/bin" && \
		$(MAKE) ARCH=arm CROSS_COMPILE=$$TARGET- \
			INSTALL_HDR_PATH=$$PREFIX/usr headers_install ) \
	&& $(touch)

# eglibc headers

stamps/unpack_eglibc: $(EGLIBC_GZ)
	@$(announce) && \
	( mkdir -p src && cd src && rm -rf "$(EGLIBC_DIR)" && tar zxf ../$(EGLIBC_GZ) ) \
	&& $(touch)

stamps/eglibc_patched: stamps/unpack_eglibc patch/eglibc_2.13-35.diff patch/eglibc_2.13-37+rpi1.diff patch/eglibc--armhf-linker.diff patch/eglibc--armhf-triplet.diff patch/eglibc--cross-cygwin.diff patch/eglibc--ldconfig-cache-abi.diff patch/eglibc--remove-manual.diff patch/eglibc--soname-hack.diff
	@$(announce) && \
	( cd $(EGLIBC_DIR) && for p in $(addprefix ../../,$(filter patch/eglibc%,$^)); do echo $$p >/dev/stderr; patch -p1 <$$p; done ) \
	&& $(touch)

stamps/eglibc_headers_configured: stamps/eglibc_patched stamps/gcc1_installed stamps/binutils_installed stamps/linux_installed
	@$(announce) && \
	( rm -rf build/eglibc && mkdir -p build/eglibc && cd build/eglibc && \
		export BUILD_CC=gcc && \
		export CC=$(INST)/bin/$(TARGET)-gcc && \
		export CXX=$(INST)/bin/$(TARGET)-g++ && \
		export AR=$(INST)/bin/$(TARGET)-ar && \
		export RANLIB=$(INST)/bin/$(TARGET)-ranlib && \
		export MAKEINFO=: && \
		../../$(EGLIBC_DIR)/configure \
		--build="$(BUILD)" \
		--host="$(TARGET)" \
		--target="$(TARGET)" \
		--prefix=/usr \
		--with-headers="$(INST)/usr/include" \
		--enable-kernel=3.0.0 \
		--disable-profile \
		--without-gd \
		--without-cvs \
		--enable-add-ons ) \
	&& $(touch)

stamps/eglibc_headers_installed: stamps/eglibc_headers_configured
	@$(announce) && \
	( cd build/eglibc && $(MAKE) install_root=$(INST) \
		install-bootstrap-headers=yes install-headers ) \
	&& $(touch)

stamps/eglibc_csu_built: stamps/eglibc_headers_installed
	@$(announce) && \
	( cd build/eglibc && mkdir -p $(INST)/usr/lib && \
		$(MAKE) csu/subdir_lib ) \
	&& $(touch)

stamps/eglibc_csu_installed: stamps/eglibc_csu_built
	@$(announce) && \
	( cd build/eglibc && cp csu/crt1.o csu/crti.o csu/crtn.o $(INST)/usr/lib && \
		$(INST)/bin/$(TARGET)-gcc -nostdlib -nostartfiles \
			-shared -x c /dev/null -o $(INST)/usr/lib/libc.so ) \
	&& $(touch)

# gcc2

stamps/gcc2_configured: stamps/eglibc_csu_installed
	@$(announce) && \
	( rm -rf build/gcc2 && mkdir -p build/gcc2 && cd build/gcc2 && $(GCC_DIR)/configure \
		--build=$(BUILD) \
		--host=$(BUILD) \
		--target=$(TARGET) \
		--prefix=$(INST) \
		--with-sysroot=$(INST) \
		--disable-libquadmath \
		--with-arch=armv6 \
		--with-fpu=vfp \
		--with-float=hard \
	    --disable-sjlj-exceptions \
		--enable-checking=release \
	    --enable-linker-build-id \
		--enable-gnu-unique-object \
		--disable-nls \
		--enable-languages=c \
		--with-headers \
		--disable-multilib \
		--disable-libmudflap \
		--disable-libssp \
		--disable-libgomp \
		--without-ppl \
		--without-cloog \
		--with-gmp=$(TEMPINST) \
		--with-mpfr=$(TEMPINST) \
		--with-mpc=$(TEMPINST) ) \
	&& $(touch)

stamps/gcc2_built: stamps/gcc2_configured
	@$(announce) && \
	( cd build/gcc2 && $(MAKE) ) \
	&& $(touch)

stamps/gcc2_installed: stamps/gcc2_built
	@$(announce) && \
	( cd build/gcc2 && $(MAKE) install ) \
	&& $(touch)

# eglibc

stamps/eglibc_configured: stamps/gcc2_installed
	@$(announce) && \
	( rm -rf build/eglibc2 && mkdir -p build/eglibc2 && cd build/eglibc2 && \
		export BUILD_CC=gcc && \
		export CC=$(INST)/bin/$(TARGET)-gcc && \
		export CXX=$(INST)/bin/$(TARGET)-g++ && \
		export AR=$(INST)/bin/$(TARGET)-ar && \
		export RANLIB=$(INST)/bin/$(TARGET)-ranlib && \
		export MAKEINFO=: && \
		../../$(EGLIBC_DIR)/configure \
		--build="$(BUILD)" \
		--host="$(TARGET)" \
		--target="$(TARGET)" \
		--prefix=/usr \
		--with-headers="$(INST)/usr/include" \
		--enable-kernel=3.0.0 \
		--disable-profile \
		--without-gd \
		--without-cvs \
		--enable-add-ons ) \
	&& $(touch)

stamps/eglibc_built: stamps/eglibc_configured
	@$(announce) && \
	( cd build/eglibc2 && $(MAKE) ) \
	&& $(touch)

stamps/eglibc_installed: stamps/eglibc_built
	@$(announce) && \
	( cd build/eglibc2 && $(MAKE) install_root=$(INST) install ) \
	&& $(touch)

# gcc final

stamps/gcc3_configured: stamps/eglibc_installed
	@$(announce) && \
	( rm -rf build/gcc3 && mkdir -p build/gcc3 && cd build/gcc3 && $(GCC_DIR)/configure \
		--build=$(BUILD) \
		--host=$(BUILD) \
		--target=$(TARGET) \
		--prefix=$(INST) \
    	--with-arch=armv6 \
		--with-fpu=vfp \
		--with-float=hard \
	    --with-sysroot=$(INST) \
		--disable-sjlj-exceptions \
		--enable-checking=release \
		--enable-linker-build-id \
		--enable-gnu-unique-object \
		--disable-nls \
		--enable-languages=c,c++ \
		--with-headers \
		--enable-shared \
		--enable-threads=posix \
		--disable-multilib \
		--enable-__cxa_atexit \
		--disable-libmudflap \
		--disable-libssp \
		--disable-libgomp \
		--without-ppl \
		--without-cloog \
		--with-gmp=$(TEMPINST) \
		--with-mpfr=$(TEMPINST) \
		--with-mpc=$(TEMPINST) ) \
	&& $(touch)

stamps/gcc3_built: stamps/gcc3_configured
	@$(announce) && \
	( cd build/gcc3 && $(MAKE) ) \
	&& $(touch)

stamps/gcc3_installed: stamps/gcc3_built
	@$(announce) && \
	( cd build/gcc3 && $(MAKE) install )\
	&& $(touch)

# gdc

stamps/gdc_downloaded:
	@$(announce) && \
	( mkdir -p src && cd src && rm -rf GDC && git clone git@github.com:epi/GDC.git && \
		cd GDC && git checkout gdc-4.7-cross-rpi ) \
	&& $(touch)

stamps/gcc_copied: stamps/gcc_patched
	@$(announce) && \
	( rm -rf $(GCC_DIR)-gdc && cp -al $(GCC_DIR) $(GCC_DIR)-gdc ) \
	&& $(touch)

stamps/gdc_patches_applied: stamps/gdc_downloaded stamps/gcc_copied
	$(announce) && \
	( cd src/GDC && ./update-gcc.sh "$(GCC_DIR)-gdc" ) \
	&& $(touch)

stamps/gdc_configured: stamps/gcc3_installed stamps/gdc_patches_applied
	@$(announce) && \
	( rm -rf build/gdc && mkdir -p build/gdc && cd build/gdc && $(GCC_DIR)-gdc/configure \
		--build=$(BUILD) \
		--host=$(BUILD) \
		--target=$(TARGET) \
		--prefix=$(INST) \
    	--with-arch=armv6 \
		--with-fpu=vfp \
		--with-float=hard \
		--with-sysroot=$(INST) \
		--disable-sjlj-exceptions \
		--enable-checking=yes \
		--enable-linker-build-id \
		--enable-gnu-unique-object \
		--disable-nls \
		--enable-languages=c,c++,d \
		--with-headers \
		--enable-shared \
		--enable-threads=posix \
		--disable-multilib \
		--enable-__cxa_atexit \
		--enable-phobos \
		--disable-bootstrap \
		--disable-libmudflap \
		--disable-libssp \
		--disable-libgomp \
		--without-ppl \
		--without-cloog \
		--with-gmp=$(TEMPINST) \
		--with-mpfr=$(TEMPINST) \
		--with-mpc=$(TEMPINST) ) \
	&& $(touch)

stamps/gdc_built: stamps/gdc_configured
	@$(announce) && \
	( cd build/gdc && DFLAGS="-fno-section-anchors" && $(MAKE) ) \
	&& $(touch)

stamps/gdc_installed: stamps/gdc_built
	@$(announce) && \
	( cd build/gdc && $(MAKE) install ) \
	&& $(touch)

# phobos

stamps/phobos_configured: stamps/gdc_installed
	@$(announce) && \
	( rm -rf build/gdc/libphobos && mkdir -p build/gdc/libphobos && cd build/gdc/libphobos && \
		export CC=$(INST)/bin/$(TARGET)-gcc && \
		export CC_FOR_BUILD=$(INST)/bin/$(TARGET)-gcc && \
		export CXX=$(INST)/bin/$(TARGET)-g++ && \
		export CXX_FOR_BUILD=$(INST)/bin/$(TARGET)-g++ && \
		export RANLIB=$(INST)/bin/$(TARGET)-ranlib && \
		export STRIP=$(INST)/bin/$(TARGET)-strip && \
		$(GCC_DIR)-gdc/libphobos/configure \
		--build=$(BUILD) \
		--host=$(TARGET) \
		--prefix=$(INST) ) \
	&& $(touch)

stamps/phobos_built: stamps/phobos_configured
	@$(announce) && \
	( cd build/gdc/libphobos && \
		export CC=$(INST)/bin/$(TARGET)-gcc && \
		export CC_FOR_BUILD=$(INST)/bin/$(TARGET)-gcc && \
		export CXX=$(INST)/bin/$(TARGET)-g++ && \
		export CXX_FOR_BUILD=$(INST)/bin/$(TARGET)-g++ && \
		export RANLIB=$(INST)/bin/$(TARGET)-ranlib && \
		export STRIP=$(INST)/bin/$(TARGET)-strip && \
		$(MAKE) CFLAGS="-fno-section-anchors" DFLAGS="-fno-section-anchors" ) \
	&& $(touch)

stamps/phobos_installed: stamps/phobos_built
	@$(announce) && \
	( cd build/gdc/libphobos && \
		$(MAKE) install && \
		echo "[Environment]" >$(INST)/bin/dmd.conf && \
		echo "DFLAGS=-I$(INST)/lib/gcc/$(TARGET)/4.7/include/d -I$(INST)/lib/gcc/$(TARGET)/4.7/include/d/$(TARGET) -q,-fno-section-anchors" >>$(INST)/bin/dmd.conf ) \
	&& $(touch)

# clean

clean-d:
	rm -f stamps/*gdc* stamps/gcc_copied stamps/*phobos*
	rm -rf src/GDC src/*gdc*
	rm -rf build/gdc

clean-phobos:
	rm -f stamps/*phobos*
	rm -rf build/gdc/phobos

clean_downloaded:
	rm -rf downloaded
.PHONY: clean_downloaded

clean:
	rm -rf stamps build src
.PHONY:clean
