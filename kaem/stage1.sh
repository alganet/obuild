ARCH=x86
PREFIX=/opt/build/musl-1.1.24
LIBDIR=/opt/build/mes-0.26/lib
PATH=/bin
BINDIR=/bin

set -ex


if sha256sum -c tcc-0.9.27-3.answers
then
    echo skip
else

if sha256sum -c sed-4.0.9.answers
then
    echo sed already built
else
    set -x
    cd /opt/build
    ungz --file /opt/build/sed-4.0.9.tar.gz --output sed-4.0.9.tar
    untar --file sed-4.0.9.tar
    rm sed-4.0.9.tar
    cd /opt/build/sed-4.0.9

    echo '
# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
# SPDX-FileCopyrightText: 2022 fosslinux <fosslinux@aussies.space>
#
# SPDX-License-Identifier: GPL-3.0-or-later

CC = tcc
AR = tcc -ar

CPPFLAGS = -DENABLE_NLS=0 \
         -DHAVE_FCNTL_H \
         -DHAVE_ALLOCA_H \
         -DSED_FEATURE_VERSION=\"4.0\" \
         -DVERSION=\"4.0.9\" \
         -DPACKAGE=\"sed\"
CFLAGS = -I . -I lib
LDFLAGS = -L . -lsed -static

.PHONY: all

ifeq ($(LIBC),mes)
    LIB_SRC = getline
else
    LIB_SRC = alloca
endif

LIB_SRC += getopt1 getopt utils regex obstack strverscmp mkstemp

LIB_OBJ = $(addprefix lib/, $(addsuffix .o, $(LIB_SRC)))

SED_SRC = compile execute regexp fmt sed
SED_OBJ = $(addprefix sed/, $(addsuffix .o, $(SED_SRC)))

all: sed/sed

lib/regex.h: lib/regex_.h
	cp $< $@

lib/regex.o: lib/regex.h

libsed.a: $(LIB_OBJ)
	$(AR) cr $@ $^

sed/sed: libsed.a $(SED_OBJ)
	$(CC) $^ $(LDFLAGS) -o $@

install:
	install -D sed/sed /bin/sed
' > Makefile

    catm config.h
    make -f Makefile LIBC=mes

    cp sed/sed /bin/sed
    chmod 755 /bin/sed
    
    cd /opt/build/
    sha256sum -o sed-4.0.9.answers /bin/sed
fi

if sha256sum -c coreutils-5.0.answers
then
    echo coreutils already built
else
    set -x
    unbz2 --file /opt/build/coreutils-5.0.tar.bz2 --output coreutils-5.0.tar
    untar --file coreutils-5.0.tar
    rm coreutils-5.0.tar
    cd /opt/build/coreutils-5.0

echo '
# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
# SPDX-FileCopyrightText: 2021 Paul Dersey <pdersey@gmail.com>
# SPDX-FileCopyrightText: 2023 Emily Trau <emily@downunderctf.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

PACKAGE=coreutils
PACKAGE_NAME=GNU\ coreutils
PACKAGE_BUGREPORT=bug-coreutils@gnu.org
PACKAGE_VERSION=5.0
VERSION=5.0

CC      = tcc
LD      = tcc
AR      = tcc -ar
LDFLAGS = -static

bindir=$(PREFIX)/bin

CFLAGS  = -I . -I lib \
          -DPACKAGE=\"$(PACKAGE)\" \
          -DPACKAGE_NAME=\"$(PACKAGE_NAME)\" \
          -DGNU_PACKAGE=\"$(PACKAGE_NAME)\" \
          -DPACKAGE_BUGREPORT=\"$(PACKAGE_BUGREPORT)\" \
          -DPACKAGE_VERSION=\"$(PACKAGE_VERSION)\" \
          -DVERSION=\"$(VERSION)\" \
          -DHAVE_LIMITS_H=1 \
          -DHAVE_DECL_FREE=1 \
          -DHAVE_DECL_MALLOC=1 \
          -DHAVE_MALLOC=1 \
          -DHAVE_STDLIB_H=1 \
          -DHAVE_REALLOC=1 \
          -DHAVE_DECL_REALLOC=1 \
          -DHAVE_DECL_GETENV=1 \
          -DHAVE_DIRENT_H=1 \
          -DHAVE_DECL___FPENDING=0 \
          -DSTDC_HEADERS=1 \
          -DHAVE_ALLOCA_H=1 \
          -DHAVE_STRUCT_TIMESPEC=1 \
          -DHAVE_STRING_H=1 \
          -DHAVE_SYS_TIME_H=1 \
          -DTIME_WITH_SYS_TIME=1 \
          -DHAVE_STDINT_H=1 \
          -DMB_LEN_MAX=16 \
          -DLIBDIR=\"$(PREFIX)/lib/mes\" \
          -DHAVE_DECL_WCWIDTH=0 \
          -DHAVE_SYS_STAT_H=1 \
          -DHAVE_INTTYPES_H=1 \
          -DHAVE_DECL_MEMCHR=1 \
          -DHAVE_MEMORY_H=1 \
          -DPENDING_OUTPUT_N_BYTES=1 \
          -DCHAR_MIN=0 \
          -DLOCALEDIR=NULL \
          -DHAVE_FCNTL_H=1 \
          -DEPERM=1 \
          -DHAVE_DECL_STRTOUL=1 \
          -DHAVE_DECL_STRTOULL=1 \
          -DHAVE_DECL_STRTOL=1 \
          -DHAVE_DECL_STRTOLL=1 \
          -DHAVE_RMDIR=1 \
          -DRMDIR_ERRNO_NOT_EMPTY=39 \
          -DHAVE_DECL_FREE=1 \
          -DENOTEMPTY=1 \
          -DLSTAT_FOLLOWS_SLASHED_SYMLINK=1 \
          -DHAVE_DECL_DIRFD=0 \
          -DLC_TIME=\"C\" \
          -DLC_COLLATE=\"C\" \
          -DHAVE_GETCWD=1 \
          -Dmy_strftime=nstrftime \
          -Dmkstemp=rpl_mkstemp \
          -DDIR_TO_FD\(Dir_p\)=-1 \
          -DUTILS_OPEN_MAX=1000 \
          -Dmajor_t=unsigned \
          -Dminor_t=unsigned

.PHONY: all install

SRC_DIR=src

COREUTILS = basename cat chmod cksum csplit cut dirname echo expand expr factor false fmt fold head hostname id join kill link ln logname mkfifo mkdir mknod nl od paste pathchk pr printf ptx pwd readlink rmdir seq sleep sort split sum tail tee tr tsort unexpand uniq unlink wc whoami test touch true yes

BINARIES = $(addprefix $(SRC_DIR)/, $(COREUTILS))

ALL=$(BINARIES) $(SRC_DIR)/cp $(SRC_DIR)/ls $(SRC_DIR)/install $(SRC_DIR)/md5sum $(SRC_DIR)/mv $(SRC_DIR)/rm $(SRC_DIR)/sha1sum
all: $(BINARIES) $(SRC_DIR)/cp $(SRC_DIR)/ls $(SRC_DIR)/install $(SRC_DIR)/md5sum $(SRC_DIR)/mv $(SRC_DIR)/rm $(SRC_DIR)/sha1sum

LIB_DIR = lib
LIB_SRC = acl posixtm posixver strftime getopt getopt1 hash hash-pjw addext argmatch backupfile basename canon-host closeout cycle-check diacrit dirname dup-safer error exclude exitfail filemode __fpending file-type fnmatch fopen-safer full-read full-write gethostname getline getstr gettime hard-locale human idcache isdir imaxtostr linebuffer localcharset long-options makepath mbswidth md5 memcasecmp memcoll modechange offtostr path-concat physmem quote quotearg readtokens rpmatch safe-read safe-write same save-cwd savedir settime sha stpcpy stripslash strtoimax strtoumax umaxtostr unicodeio userspec version-etc xgetcwd xgethostname xmalloc xmemcoll xnanosleep xreadlink xstrdup xstrtod xstrtol xstrtoul xstrtoimax xstrtoumax yesno strnlen getcwd sig2str mountlist regex canonicalize mkstemp memrchr euidaccess ftw dirfd obstack strverscmp strftime tempname tsearch

LIB_OBJECTS = $(addprefix $(LIB_DIR)/, $(addsuffix .o, $(LIB_SRC)))

$(SRC_DIR)/false.c: $(SRC_DIR)/true.c
	cp $< $@
	sed -i -e s/true/false/g \
          -e s/success/failure/g \
          -e '\''s/(EXIT_SUCCESS)/(EXIT_FAILURE)/g'\'' \
          $@

$(LIB_DIR)/libfettish.a: $(LIB_OBJECTS)
	$(AR) cr $@ $^

$(BINARIES) : % : %.o $(LIB_DIR)/libfettish.a
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

$(SRC_DIR)/cp: $(SRC_DIR)/cp.o $(SRC_DIR)/copy.o $(SRC_DIR)/cp-hash.c $(LIB_DIR)/libfettish.a
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

$(SRC_DIR)/install: $(SRC_DIR)/install.o $(SRC_DIR)/copy.o $(SRC_DIR)/cp-hash.c $(LIB_DIR)/libfettish.a
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

$(SRC_DIR)/ls: $(SRC_DIR)/ls.o $(SRC_DIR)/ls-ls.o $(LIB_DIR)/libfettish.a
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

$(SRC_DIR)/md5sum: $(SRC_DIR)/md5.o $(SRC_DIR)/md5sum.o $(LIB_DIR)/libfettish.a
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

$(SRC_DIR)/mv: $(SRC_DIR)/mv.o $(SRC_DIR)/copy.o $(SRC_DIR)/remove.o $(SRC_DIR)/cp-hash.o $(LIB_DIR)/libfettish.a
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

$(SRC_DIR)/rm: $(SRC_DIR)/rm.o $(SRC_DIR)/remove.o $(LIB_DIR)/libfettish.a
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

$(SRC_DIR)/sha1sum: $(SRC_DIR)/sha1sum.o $(SRC_DIR)/md5sum.o $(LIB_DIR)/libfettish.a
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

install: $(ALL)
	$(SRC_DIR)/install $^ $(bindir)
' > Makefile

    export PREFIX=/

    # Patch and prepare
    cp lib/fnmatch_.h lib/fnmatch.h
    cp lib/ftw_.h lib/ftw.h
    cp lib/search_.h lib/search.h
    catm config.h

    rm src/dircolors.h
    patch -Np0 -i /opt/kaem/coreutils/modechange.patch
    patch -Np0 -i /opt/kaem/coreutils/mbstate.patch
    patch -Np0 -i /opt/kaem/coreutils/expr-strcmp.patch
    patch -Np0 -i /opt/kaem/coreutils/sort-locale.patch
    patch -Np0 -i /opt/kaem/coreutils/touch-getdate.patch
    patch -Np0 -i /opt/kaem/coreutils/ls-strcmp.patch
    patch -Np0 -i /opt/kaem/coreutils/tac-uint64.patch
    
    make -f Makefile PREFIX=${PREFIX}
    make -f Makefile PREFIX=${PREFIX} install

    cd /opt/build/
    sha256sum -o coreutils-5.0.answers \
        /bin/install \
        /bin/basename \
        /bin/cat \
        /bin/chmod \
        /bin/cksum \
        /bin/csplit \
        /bin/cut \
        /bin/dirname \
        /bin/echo \
        /bin/expand \
        /bin/factor \
        /bin/false \
        /bin/fmt \
        /bin/fold \
        /bin/head \
        /bin/hostname \
        /bin/id \
        /bin/join \
        /bin/kill \
        /bin/link \
        /bin/ln \
        /bin/logname \
        /bin/mkfifo \
        /bin/mkdir \
        /bin/mknod \
        /bin/nl \
        /bin/od \
        /bin/paste \
        /bin/pathchk \
        /bin/pr \
        /bin/printf \
        /bin/ptx \
        /bin/pwd \
        /bin/readlink \
        /bin/rmdir \
        /bin/seq \
        /bin/sleep \
        /bin/split \
        /bin/sum \
        /bin/tail \
        /bin/tee \
        /bin/tr \
        /bin/tsort \
        /bin/unexpand \
        /bin/uniq \
        /bin/unlink \
        /bin/wc \
        /bin/whoami \
        /bin/test \
        /bin/true \
        /bin/yes \
        /bin/cp \
        /bin/install \
        /bin/md5sum \
        /bin/mv \
        /bin/rm \
        /bin/sha1sum 
fi

if sha256sum -c musl-1.1.24.answers
then
    echo musl already built
else
    set -x
    cd /opt/build
    ungz --file /opt/build/musl-1.1.24.tar.gz --output musl-1.1.24.tar
    untar --file musl-1.1.24.tar
    rm musl-1.1.24.tar
    cd /opt/build/musl-1.1.24

    patch -Np0 -i /opt/kaem/musl/avoid_set_thread_area.patch
    patch -Np0 -i /opt/kaem/musl/avoid_sys_clone.patch
    patch -Np0 -i /opt/kaem/musl/fenv.patch
    patch -Np0 -i /opt/kaem/musl/madvise_preserve_errno.patch
    patch -Np0 -i /opt/kaem/musl/makefile.patch
    patch -Np0 -i /opt/kaem/musl/set_thread_area.patch
    patch -Np0 -i /opt/kaem/musl/sigsetjmp.patch
    patch -Np0 -i /opt/kaem/musl/va_list.patch

    rm -rf src/complex

    export SOURCE_DATE_EPOCH=0
    export KBUILD_BUILD_TIMESTAMP='@0'
    
    export LIBDIR=/opt/build/musl-1.1.24/lib

    PREFIX=/ CC=tcc bash ./configure \
      --host=i386 \
      --disable-shared \
      --prefix="/" \
      --libdir="/opt/build/musl-1.1.24/lib" \
      --includedir="/opt/build/musl-1.1.24/include"
    
    make CROSS_COMPILE= AR="tcc -ar" RANLIB=true CFLAGS="-DSYSCALL_NO_TLS"
    chmod +x ./tools/install.sh
    make install

    cd /opt/build
    sha256sum -o musl-1.1.24.answers /opt/build/musl-1.1.24/lib/libc.a
fi


if sha256sum -c tcc-0.9.27-2.answers
then
    echo tcc already built
else
    set -x
    unbz2 --file /opt/build/tcc-0.9.27.tar.bz2 --output /opt/build/tcc-0.9.27.tar
    untar --file /opt/build/tcc-0.9.27.tar
    cd /opt/build/tcc-0.9.27

    patch -Np0 -i /opt/kaem/tcc/dont-skip-weak-symbols-ar.patch
    patch -Np0 -i /opt/kaem/tcc/ignore-static-inside-array.patch
    patch -Np0 -i /opt/kaem/tcc/static-link.patch

    catm config.h
    export LIBDIR=/opt/build/musl-1.1.24/lib
    
    ln -sf "/opt/build/mes-0.26/lib/tcc/libtcc1.a" ./libtcc1.a

    for TCC in tcc-0.9.26 ./tcc-musl; do
        "${TCC}" \
            -v \
            -static \
            -o tcc-musl \
            -D TCC_TARGET_I386=1 \
            -D CONFIG_TCCDIR=\"${LIBDIR}/tcc\" \
            -D CONFIG_TCC_CRTPREFIX=\"${LIBDIR}\" \
            -D CONFIG_TCC_ELFINTERP=\"/mes/loader\" \
            -D CONFIG_TCC_LIBPATHS=\"${LIBDIR}:${LIBDIR}/tcc\" \
            -D CONFIG_TCC_SYSINCLUDEPATHS=\"/opt/build/musl-1.1.24/include\" \
            -D TCC_LIBGCC=\"${LIBDIR}/libc.a\" \
            -D CONFIG_TCC_STATIC=1 \
            -D CONFIG_USE_LIBGCC=1 \
            -D TCC_VERSION=\"0.9.27\" \
            -D ONE_SOURCE=1 \
            -B . \
            tcc.c

        # libtcc1.a
        rm -f libtcc1.a
        ${TCC} -c -D HAVE_CONFIG_H=1 lib/libtcc1.c
        ${TCC} -ar cr libtcc1.a libtcc1.o
    done

    install -D tcc-musl "/bin/tcc-musl"
    install -D libtcc1.a "/opt/build/musl-1.1.24/lib/tcc/libtcc1.a"

    cd /opt/build/
    sha256sum -o tcc-0.9.27-2.answers ${BINDIR}/tcc-musl
fi


if sha256sum -c musl-1.1.24-1.answers
then
    echo musl already built
else
    set -x
    cd /opt/build
    ungz --file /opt/build/musl-1.1.24.tar.gz --output musl-1.1.24.tar
    untar --file musl-1.1.24.tar
    rm musl-1.1.24.tar
    cd /opt/build/musl-1.1.24

    patch -Np0 -i /opt/kaem/musl/avoid_set_thread_area.patch
    patch -Np0 -i /opt/kaem/musl/avoid_sys_clone.patch
    patch -Np0 -i /opt/kaem/musl/fenv.patch
    patch -Np0 -i /opt/kaem/musl/madvise_preserve_errno.patch
    patch -Np0 -i /opt/kaem/musl/makefile.patch
    patch -Np0 -i /opt/kaem/musl/set_thread_area.patch
    patch -Np0 -i /opt/kaem/musl/sigsetjmp.patch
    patch -Np0 -i /opt/kaem/musl/va_list.patch

    rm -rf src/complex

    export SOURCE_DATE_EPOCH=0
    export KBUILD_BUILD_TIMESTAMP='@0'
    
    export LIBDIR=/opt/build/musl-1.1.24/lib

    PREFIX=/ CC=tcc-musl bash ./configure \
      --host=i386 \
      --disable-shared \
      --prefix="/" \
      --libdir="/opt/build/musl-1.1.24/lib" \
      --includedir="/opt/build/musl-1.1.24/include"
    
    make CROSS_COMPILE= AR="tcc -ar" RANLIB=true CFLAGS="-DSYSCALL_NO_TLS"
    chmod +x ./tools/install.sh
    make install

    cd /opt/build/tcc-0.9.27
    install -D libtcc1.a "/opt/build/musl-1.1.24/lib/tcc/libtcc1.a"

    cd /opt/build
    sha256sum -o musl-1.1.24-1.answers /opt/build/musl-1.1.24/lib/libc.a
fi

if sha256sum -c tcc-0.9.27-3.answers
then
    echo tcc already built
else
    set -x
    unbz2 --file /opt/build/tcc-0.9.27.tar.bz2 --output /opt/build/tcc-0.9.27.tar
    untar --file /opt/build/tcc-0.9.27.tar
    cd /opt/build/tcc-0.9.27

    replace --file ./tcctools.c --match-on "    if (ret == 1)
        return ar_usage(ret);

    if ((fh = fopen(argv[i_lib], \"wb\")) == NULL)
    {
        fprintf(stderr, \"tcc: ar: can't open file %s \\n\", argv[i_lib]);
        goto the_end;
    }" --replace-with "    if (ret == 1)
        return ar_usage(ret);"

    replace --file ./tcctools.c --match-on "    // write header" --replace-with "    if ((fh = fopen(argv[i_lib], \"wb\")) == NULL)
    {
        fprintf(stderr, \"tcc: ar: can't open file %s \\n\", argv[i_lib]);
        goto the_end;
    }

    // write header"

    patch -Np0 -i /opt/kaem/tcc/dont-skip-weak-symbols-ar.patch
    patch -Np0 -i /opt/kaem/tcc/ignore-static-inside-array.patch
    patch -Np0 -i /opt/kaem/tcc/static-link.patch

    catm config.h
    export LIBDIR=/opt/build/musl-1.1.24/lib
    
    tcc-musl \
        -v \
        -static \
        -o tcc-musl \
        -D TCC_TARGET_I386=1 \
        -D CONFIG_TCCDIR=\"${LIBDIR}/tcc\" \
        -D CONFIG_TCC_CRTPREFIX=\"${LIBDIR}\" \
        -D CONFIG_TCC_ELFINTERP=\"/mes/loader\" \
        -D CONFIG_TCC_LIBPATHS=\"${LIBDIR}:${LIBDIR}/tcc\" \
        -D CONFIG_TCC_SYSINCLUDEPATHS=\"/opt/build/musl-1.1.24/include\" \
        -D TCC_LIBGCC=\"${LIBDIR}/libc.a\" \
        -D CONFIG_TCC_STATIC=1 \
        -D CONFIG_USE_LIBGCC=1 \
        -D TCC_VERSION=\"0.9.27\" \
        -D ONE_SOURCE=1 \
        tcc.c

    # libtcc1.a
    tcc-musl -c -D HAVE_CONFIG_H=1 lib/libtcc1.c
    tcc-musl -ar cr libtcc1.a libtcc1.o

    install -D tcc-musl "/bin/tcc-musl"
    install -D libtcc1.a "/opt/build/musl-1.1.24/lib/tcc/libtcc1.a"

    cd /opt/build/
    sha256sum -o tcc-0.9.27-3.answers ${BINDIR}/tcc-musl
fi
fi # skip


if sha256sum -c tar-1.12.answers
then
    echo tar already built
else
    set -x
    ungz --file /opt/build/tar-1.12.tar.gz --output /opt/build/tar-1.12.tar
    untar --file /opt/build/tar-1.12.tar
    cd /opt/build/tar-1.12

cat <<'MAKEFILE' > Makefile
# SPDX-FileCopyrightText: 2022 Andrius Štikonas <andrius@stikonas.eu>
#
# SPDX-License-Identifier: GPL-3.0-or-later

CC = tcc
AR = tcc -ar

# -DSIZEOF_UNSIGNED_LONG=4 forces use of simulated arithmetic
# This is to avoid running configure test to determine sizeof(long long)
CPPFLAGS = -DHAVE_FCNTL_H \
         -DHAVE_DIRENT_H \
         -DHAVE_GETCWD_H \
         -DHAVE_GETCWD \
         -DSIZEOF_UNSIGNED_LONG=4 \
         -DVERSION=\"1.12\" \
         -DPACKAGE=\"tar\"

CFLAGS = -I . -I lib
LDFLAGS = -L . -ltar -static

.PHONY: all

LIB_SRC = argmatch backupfile error fnmatch ftruncate getdate_stub getopt getopt1 getversion modechange msleep xgetcwd xmalloc xstrdup

LIB_OBJ = $(addprefix lib/, $(addsuffix .o, $(LIB_SRC)))

TAR_SRC = arith buffer compare create delete extract incremen list mangle misc names open3 rtapelib tar update
TAR_OBJ = $(addprefix src/, $(addsuffix .o, $(TAR_SRC)))

all: tar

libtar.a: $(LIB_OBJ)
	$(AR) cr $@ $^

tar: libtar.a $(TAR_OBJ)
	$(CC) $^ $(LDFLAGS) -o $@
MAKEFILE


cat <<'GETDATE' > lib/getdate_stub.c
/*
 * SPDX-FileCopyrightText: 2021 Paul Dersey <pdersey@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "getdate.h"

time_t get_date (const char *p, const time_t *now)
{
    return 0;
}
GETDATE
cat <<'STAT' > stat_stub
/*
 * SPDX-FileCopyrightText: 2022 fosslinux <fosslinux@aussies.space>
 * SPDX-FileCopyrightText: 2022 Andrius Štikonas <andrius@stikonas.eu>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include <sys/stat.h>
#include <linux/syscall.h>
#include <linux/x86/syscall.h>

int _lstat(const char *path, struct stat *buf) {
	int rc = lstat(path, buf);
	if (rc == 0) {
		buf->st_atime = 0;
		buf->st_mtime = 0;
	}
	return rc;
}

/* stat is deliberately hacked to be lstat.
   In src/system.h tar already defines lstat to be stat
   since S_ISLNK is not defined in mes C library
   Hence, we can't use something like #define lstat(a,b) _lstat(a,b)
   to have separate stat and lstat functions.
   Thus here we break tar with --dereference option but we don't use
   this option in live-bootstrap.
 */
#define stat(a,b) _lstat(a,b)
STAT
    catm src/create.c.new stat_stub src/create.c
    cp src/create.c.new src/create.c

    # Build
    make -f Makefile

    # Install
    cp tar /bin/tar
    chmod 755 /bin/tar

    cd /opt/build/
    sha256sum -o tar-1.12.answers ${BINDIR}/tar
fi

if sha256sum -c gzip-1.2.4.answers
then
    echo gzip already built
else
    set -x
    ungz --file /opt/build/gzip-1.2.4.tar.gz --output /opt/build/gzip-1.2.4.tar
    untar --file /opt/build/gzip-1.2.4.tar
    cd /opt/build/gzip-1.2.4

    cat <<'MAKEFILE2' > Makefile
# SPDX-FileCopyrightText: 2022 Andrius Štikonas <andrius@stikonas.eu>
#
# SPDX-License-Identifier: GPL-3.0-or-later

CC = tcc
AR = tcc -ar

CPPFLAGS = -DNO_UTIME \
         -Dstrlwr=unused

CFLAGS = -I .
LDFLAGS = -static

.PHONY: all

GZIP_SRC = gzip bits crypt deflate getopt inflate lzw trees unlzh unlzw unpack unzip util zip
GZIP_OBJ = $(addsuffix .o, $(GZIP_SRC))

all: gzip

gzip: $(GZIP_OBJ)
	$(CC) $(LDFLAGS) $^ -o $@
MAKEFILE2
    cat <<'STAT2' > stat_override
/*
 * SPDX-FileCopyrightText: 2022 fosslinux <fosslinux@aussies.space>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include <sys/stat.h>
#include <linux/syscall.h>
#include <linux/x86/syscall.h>

int _stat(const char *path, struct stat *buf) {
	int rc = stat(path, buf);
	if (rc == 0) {
		buf->st_atime = 0;
		buf->st_mtime = 0;
	}
	return rc;
}

int _lstat(const char *path, struct stat *buf) {
	int rc = lstat(path, buf);
	if (rc == 0) {
		buf->st_atime = 0;
		buf->st_mtime = 0;
	}
	return rc;
}

#define stat(a,b) _stat(a,b)
#define lstat(a,b) _lstat(a,b)
STAT2
    catm gzip.c.new stat_override gzip.c
    cp gzip.c.new gzip.c

    patch -Np0 -i /opt/kaem/gzip/makecrc-write-to-file.patch
    patch -Np0 -i /opt/kaem/gzip/removecrc.patch

    tcc -static -o makecrc sample/makecrc.c
    ./makecrc
    catm util.c.new util.c crc.c
    cp util.c.new util.c

    # Build
    make

    # Install
    cp gzip /bin/gzip
    cp gzip /bin/gunzip
    chmod 755 /bin/gzip
    chmod 755 /bin/gunzip

    cd /opt/build/
    sha256sum -o gzip-1.2.4.answers ${BINDIR}/gzip
fi


if sha256sum -c grep-2.4.answers
then
    echo grep already built
else
    set -x
    gunzip -c /opt/build/grep-2.4.tar.gz > /opt/build/grep-2.4.tar
    tar -xf /opt/build/grep-2.4.tar
    rm /opt/build/grep-2.4.tar
    cd /opt/build/grep-2.4

    cat <<'MAKEFILE3' > Makefile
# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
# SPDX-FileCopyrightText: 2022 fosslinux <fosslinux@aussies.space>
#
# SPDX-License-Identifier: GPL-3.0-or-later

PACKAGE=grep
VERSION=2.4

CC      = tcc
LD      = tcc
AR      = tcc -ar

CFLAGS  = -DPACKAGE=\"$(PACKAGE)\" \
          -DVERSION=\"$(VERSION)\" \
          -DHAVE_DIRENT_H=1 \
          -DHAVE_UNISTD_H=1 \
          -DHAVE_STRERROR=1 \
          -DREGEX_MALLOC=1

.PHONY: all

GREP_SRC = grep dfa kwset obstack regex stpcpy savedir getopt getopt1 search grepmat
GREP_OBJECTS = $(addprefix src/, $(addsuffix .o, $(GREP_SRC)))

all: grep

grep: $(GREP_OBJECTS)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

install: all
	install -D grep /bin/grep
	ln -sf $(PREFIX)/bin/grep /bin/egrep
	ln -sf $(PREFIX)/bin/grep /bin/fgrep
MAKEFILE3

    make
    make install

    cd /opt/build/
    sha256sum -o grep-2.4.answers ${BINDIR}/grep
fi

if sha256sum -c gawk-3.0.4.answers
then
    echo gawk already built
else
    set -x
    gunzip -c /opt/build/gawk-3.0.4.tar.gz > /opt/build/gawk-3.0.4.tar
    tar -xf /opt/build/gawk-3.0.4.tar
    rm /opt/build/gawk-3.0.4.tar
    cd /opt/build/gawk-3.0.4

    export LIBDIR=/opt/build/musl-1.1.24/lib
    cat <<'MAKEFILE4' > Makefile
# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
# SPDX-FileCopyrightText: 2021 Paul Dersey <pdersey@gmail.com>
# SPDX-FileCopyrightText: 2022 fosslinux <fosslinux@aussies.space>

# SPDX-License-Identifier: GPL-3.0-or-later

CC      = tcc-musl

CFLAGS = -nostdinc -I vms \
         -I "/opt/build/musl-1.1.24/include" \
         -DC_ALLOCA=1 \
         -DGETGROUPS_T=gid_t \
         -DGETPGRP_VOID=1 \
         -DHAVE_MMAP=1 \
         -DSTDC_HEADERS=1 \
         -DREGEX_MALLOC=1 \
         -DRETSIGTYPE=void \
         -DSPRINTF_RET=int \
         -DHAVE_VPRINTF=1 \
         -DHAVE_STDARG_H=1 \
         -DDEFPATH=\"$(PREFIX)/share/awk\" \
         -DHAVE_SYSTEM=1 \
         -DHAVE_TZSET=1 \
         -DHAVE_LIMITS_H=1 \
         -DHAVE_LOCALE_H=1 \
         -DHAVE_MEMORY_H=1 \
         -DHAVE_STDARG_H=1 \
         -DHAVE_MEMCMP=1 \
         -DHAVE_MEMCPY=1 \
         -DHAVE_MEMSET=1 \
         -DHAVE_STRERROR=1 \
         -DHAVE_STRNCASECMP=1 \
         -DHAVE_STRFTIME=1 \
         -DHAVE_STRING_H=1 \
         -DHAVE_STRTOD=1 \
         -DHAVE_SYS_PARAM_H=1 \
         -DHAVE_UNISTD_H=1 \
         -DBITOPS=1

.PHONY: all

GAWK_SRC = alloca array awktab builtin dfa eval field getopt getopt1 gawkmisc io main missing msg node random re regex version
GAWK_OBJ = $(addsuffix .o, $(GAWK_SRC))

all: gawk

gawk: $(GAWK_OBJ)
	$(CC) -o $@ $^

install: all
	install -D gawk /bin/gawk
	ln -s $(PREFIX)/bin/gawk /bin/awk
MAKEFILE4

    export PREFIX=

    make
    make install || :
    
    install -d "/share/awk/"
    for file in awklib/eg/lib/*.awk; do
        install -m 644 "$file" "/share/awk/"
    done

    gawk --version

    cd /opt/build/
    sha256sum -o gawk-3.0.4.answers ${BINDIR}/gawk
fi

if sha256sum -c diffutils-2.7.answers
then
    echo diffutils already built
else
    set -x
    gunzip -c /opt/build/diffutils-2.7.tar.gz > /opt/build/diffutils-2.7.tar
    tar -xf /opt/build/diffutils-2.7.tar
    rm /opt/build/diffutils-2.7.tar
    cd /opt/build/diffutils-2.7

cat <<'MAKEFILE5' > Makefile
# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
# SPDX-FileCopyrightText: 2022 fosslinux <fosslinux@aussies.space>
#
# SPDX-License-Identifier: GPL-3.0-or-later

CC      = tcc-musl

CFLAGS  = -I . \
          -DNULL_DEVICE=\"/dev/null\" \
          -DHAVE_STRERROR=1 \
          -DREGEX_MALLOC=1 \
          -DHAVE_DIRENT_H \
          -DHAVE_DUP2=1 \
          -DHAVE_FORK=1

.PHONY: all

CMP_SRC = cmp cmpbuf error getopt getopt1 xmalloc version
CMP_OBJECTS = $(addsuffix .o, $(CMP_SRC))

DIFF_SRC = diff alloca analyze cmpbuf dir io util context ed ifdef normal side fnmatch getopt getopt1 regex version
DIFF_OBJECTS = $(addsuffix .o, $(DIFF_SRC))

all: cmp diff

cmp: $(CMP_OBJECTS)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

diff: $(DIFF_OBJECTS)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

install: all
	install -D cmp $(DESTDIR)$(PREFIX)/bin/cmp
	install diff $(DESTDIR)$(PREFIX)/bin
MAKEFILE5

    touch config.h
    make
    make install

    cd /opt/build/
    sha256sum -o diffutils-2.7.answers ${BINDIR}/cmp
fi


if sha256sum -c sed-4.0.9-1.answers
then
    echo sed already built
else
    set -x
    cd /opt/build
    ungz --file /opt/build/sed-4.0.9.tar.gz --output sed-4.0.9.tar
    untar --file sed-4.0.9.tar
    rm sed-4.0.9.tar
    cd /opt/build/sed-4.0.9

    echo '
# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
# SPDX-FileCopyrightText: 2022 fosslinux <fosslinux@aussies.space>
#
# SPDX-License-Identifier: GPL-3.0-or-later

CC = tcc-musl
AR = tcc-musl -ar

CPPFLAGS = -DENABLE_NLS=0 \
         -DHAVE_FCNTL_H \
         -DHAVE_ALLOCA_H \
         -DSED_FEATURE_VERSION=\"4.0\" \
         -DVERSION=\"4.0.9\" \
         -DPACKAGE=\"sed\"
CFLAGS = -I . -I lib
LDFLAGS = -L . -lsed -static

.PHONY: all

ifeq ($(LIBC),mes)
    LIB_SRC = getline
else
    LIB_SRC = alloca
endif

LIB_SRC += getopt1 getopt utils regex obstack strverscmp mkstemp

LIB_OBJ = $(addprefix lib/, $(addsuffix .o, $(LIB_SRC)))

SED_SRC = compile execute regexp fmt sed
SED_OBJ = $(addprefix sed/, $(addsuffix .o, $(SED_SRC)))

all: sed/sed

lib/regex.h: lib/regex_.h
	cp $< $@

lib/regex.o: lib/regex.h

libsed.a: $(LIB_OBJ)
	$(AR) cr $@ $^

sed/sed: libsed.a $(SED_OBJ)
	$(CC) $^ $(LDFLAGS) -o $@

install:
	install -D sed/sed /bin/sed
' > Makefile

    catm config.h
    make

    cp sed/sed /bin/sed
    chmod 755 /bin/sed
    cd /opt/build/
    sha256sum -o sed-4.0.9-1.answers /bin/sed
fi



if sha256sum -c binutils-2.30.answers
then
    echo binutils already built
else
    set -x
    gunzip -c /opt/build/binutils-2.30.tar.gz > /opt/build/binutils-2.30.tar
    tar -xf /opt/build/binutils-2.30.tar
    rm /opt/build/binutils-2.30.tar
    cd /opt/build/binutils-2.30

    patch -Np0 -i /opt/kaem/binutils/libiberty-add-missing-config-directory-reference.patch
    patch -Np0 -i /opt/kaem/binutils/new-gettext.patch
    patch -Np0 -i /opt/kaem/binutils/opcodes-ensure-i386-init-dependencies-are-satisfied.patch

    export PREFIX=/
    export LIBDIR=/opt/build/musl-1.1.24/lib

    for dir in intl libiberty opcodes bfd binutils gas gprof ld zlib; do
    (
        cd $dir

        LD="true" AR="tcc-musl -ar" CC="tcc-musl" ./configure \
            --disable-nls \
            --enable-deterministic-archives \
            --enable-64-bit-bfd \
            --build=i386-unknown-linux-gnu \
            --host=i386-unknown-linux-gnu \
            --target=i386-unknown-linux-gnu \
            --program-prefix="" \
            --prefix="${PREFIX}" \
            --libdir="${LIBDIR}" \
            --with-sysroot= \
            --srcdir=. \
            --enable-compressed-debug-sections=all \
            lt_cv_sys_max_cmd_len=32768
    )
    done
    
    make -C bfd headers

    for dir in libiberty zlib bfd opcodes binutils gas gprof ld; do
        make -C $dir tooldir=${PREFIX} CPPFLAGS="-DPLUGIN_LITTLE_ENDIAN" MAKEINFO=true
    done

    for dir in libiberty zlib bfd opcodes binutils gas gprof ld; do
        make -C $dir tooldir=${PREFIX} DESTDIR="${DESTDIR}" install MAKEINFO=true
    done

    cd /opt/build/
    sha256sum -o binutils-2.30.answers ${BINDIR}/as
fi

if sha256sum -c gcc-4.0.4.answers
then
    echo gcc already built
else
    set -x
    gunzip -c /opt/build/gcc-core-4.0.4.tar.gz > /opt/build/gcc-core-4.0.4.tar
    tar -xf /opt/build/gcc-core-4.0.4.tar
    rm /opt/build/gcc-core-4.0.4.tar
    cd /opt/build/gcc-4.0.4

    cp -f /opt/kaem/config.guess .
    cp -f /opt/kaem/config.sub .
    
    # This is needed for building with TCC
    sed -i 's/ix86_attribute_table\[\]/ix86_attribute_table\[10\]/' gcc/config/i386/i386.c
    # Needed for musl
    sed -i 's/struct siginfo/siginfo_t/' gcc/config/i386/linux-unwind.h

    #rm fixincludes/fixincl.x

    mkdir -p build
    cd build

    export PREFIX=/
    export LIBDIR=/opt/build/musl-1.1.24/lib

    for dir in libiberty libcpp gcc; do
        mkdir -p $dir
        cd $dir
        CC=tcc-musl CFLAGS="-D HAVE_ALLOCA_H" ../../$dir/configure \
            --prefix="${PREFIX}" \
            --libdir="${LIBDIR}" \
            --build=i386-unknown-linux-musl \
            --target=i386-unknown-linux-musl \
            --host=i386-unknown-linux-musl \
            --with-sysroot= \
            --disable-shared
        cd ..
    done
    cd ..


    sed -i 's/C_alloca/alloca/g' libiberty/alloca.c
    sed -i 's/C_alloca/alloca/g' include/libiberty.h

    ln -s . build/build-i386-unknown-linux-musl
    mkdir build/gcc/include
    ln -s ../../../gcc/gsyslimits.h build/gcc/include/syslimits.h
    
    rm -f /opt/build/musl-1.1.24/lib/ldscripts
    ln -s /lib/ldscripts /opt/build/musl-1.1.24/lib/ldscripts

    export LIBGCC2_INCLUDES='-I"/opt/build/musl-1.1.24/include" -I"/include"'
    export CPATH="/opt/build/musl-1.1.24/include"
    export LIBRARY_PATH=-I"/opt/build/musl-1.1.24/lib"

    for dir in libiberty libcpp gcc; do
        make -C build/$dir STMP_FIXINC=
    done

    DESTDIR=
    mkdir -p "${DESTDIR}${LIBDIR}/gcc/i386-unknown-linux-musl/4.0.4/install-tools/include"
    make -C build/gcc install STMP_FIXINC= DESTDIR="${DESTDIR}"
    mkdir -p "${DESTDIR}${LIBDIR}/gcc/i386-unknown-linux-musl/4.0.4/include"
    rm "${DESTDIR}${LIBDIR}/gcc/i386-unknown-linux-musl/4.0.4/include/syslimits.h"
    cp  gcc/gsyslimits.h "${DESTDIR}${LIBDIR}/gcc/i386-unknown-linux-musl/4.0.4/include/syslimits.h"

    cd /opt/build/
    sha256sum -o gcc-4.0.4.answers ${BINDIR}/i386-unknown-linux-musl-gcc
fi


if sha256sum -c m4-1.4.7.answers
then
    echo m4 already built
else
    set -x
    unbz2 --file /opt/build/m4-1.4.7.tar.bz2 --output /opt/build/m4-1.4.7.tar
    tar -xf /opt/build/m4-1.4.7.tar
    rm /opt/build/m4-1.4.7.tar
    cd /opt/build/m4-1.4.7
    
    cat <<'MAKEFILE6'
# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
# SPDX-FileCopyrightText: 2022 fosslinux <fosslinux@aussies.space>

# SPDX-License-Identifier: GPL-3.0-or-later

CC      = tcc-musl
AR      = tcc-musl -ar

CFLAGS  = -I lib \
          -DVERSION=\"1.4.7\" \
          -DPACKAGE_BUGREPORT=\"bug-m4@gnu.org\" \
          -DPACKAGE_STRING=\"GNU\ M4\ 1.4.7\" \
          -DPACKAGE=\"m4\" \
          -DPACKAGE_NAME=\"GNU\ M4\" \
          -DHAVE_STDINT_H=1 \
          -DHAVE___FPENDING=1 \
          -DHAVE_DECL___FPENDING=1 \
          -D_GNU_SOURCE=1 \
          -D_GL_UNUSED= \
          -D__getopt_argv_const=const \
          -DSYSCMD_SHELL=\"/bin/sh\"

LDFLAGS = -L . -lm4

.PHONY: all

LIB_SRC = cloexec close-stream dup-safer error exitfail fd-safer fopen-safer getopt getopt1 mkstemp-safer regex obstack tmpfile-safer verror xalloc-die xasprintf xmalloc xvasprintf
LIB_OBJECTS = $(addprefix lib/, $(addsuffix .o, $(LIB_SRC)))

M4_SRC = m4 builtin debug eval format freeze input macro output path symtab
M4_OBJ = $(addprefix src/, $(addsuffix .o, $(M4_SRC)))

all: src/m4

src/m4: libm4.a $(M4_OBJ)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

libm4.a: $(LIB_OBJECTS)
	$(AR) cr $@ $^

%.o : %.c lib/config.h
	$(CC) -c -o $@ $< $(CFLAGS)

lib/config.h:
	touch lib/config.h

install: all
	install -D src/m4 $(DESTDIR)$(PREFIX)/bin/m4    
MAKEFILE6

    export PREFIX=/
    export LIBDIR=/opt/build/musl-1.1.24/lib

    cp -f /opt/kaem/config.guess .
    cp -f /opt/kaem/config.sub .

    CC=tcc-musl ./configure \
        --prefix="${PREFIX}" \
        --host=i386-unknown-linux-musl \
        --build=i386-unknown-linux-gnu \
        --libdir="${LIBDIR}" 

    make MAKEINFO=true DESTDIR="${DESTDIR}"
    make MAKEINFO=true DESTDIR="${DESTDIR}" install

    cd /opt/build/
    sha256sum -o m4-1.4.7.answers ${BINDIR}/m4
fi

if sha256sum -c gmp-6.2.1.answers
then
    echo gmp already built
else
    set -x
    unbz2 --file /opt/build/gmp-6.2.1.tar.bz2 --output /opt/build/gmp-6.2.1.tar
    tar -xf /opt/build/gmp-6.2.1.tar
    rm /opt/build/gmp-6.2.1.tar
    cd /opt/build/gmp-6.2.1

    export PREFIX=/
    export LIBDIR=/opt/build/musl-1.1.24/lib
    export LIBGCC2_INCLUDES='-I"/opt/build/musl-1.1.24/include" -I"/include"'
    export CPATH="/opt/build/musl-1.1.24/include:/include"
    export LIBRARY_PATH="/opt/build/musl-1.1.24/lib"
    export CC="i386-unknown-linux-musl-gcc"
    export CPP="i386-unknown-linux-musl-cpp"

    cp -f /opt/kaem/config.guess .
    cp -f /opt/kaem/config.sub .
    
    ./configure \
        --prefix="${PREFIX}" \
        --libdir="${LIBDIR}" \
        --host=i386-unknown-linux-musl \
        --build=i386-unknown-linux-musl \
        --disable-shared

    make MAKEINFO=true DESTDIR="${DESTDIR}"
    make MAKEINFO=true DESTDIR="${DESTDIR}" install

    cd /opt/build/
    sha256sum -o gmp-6.2.1.answers /include/gmp.h
fi

if sha256sum -c mpfr-4.1.0.answers
then
    echo mpfr already built
else
    set -x
    gunzip -c /opt/build/mpfr-4.1.0.tar.gz > /opt/build/mpfr-4.1.0.tar
    tar -xf /opt/build/mpfr-4.1.0.tar
    rm /opt/build/mpfr-4.1.0.tar
    cd /opt/build/mpfr-4.1.0

    export PREFIX=/
    export LIBDIR=/opt/build/musl-1.1.24/lib
    export LIBGCC2_INCLUDES='-I"/opt/build/musl-1.1.24/include" -I"/include"'
    export CPATH="/opt/build/musl-1.1.24/include:/include"
    export LIBRARY_PATH="/opt/build/musl-1.1.24/lib"

    cp -f /opt/kaem/config.guess .
    cp -f /opt/kaem/config.sub .
    
    ./configure \
        --prefix="${PREFIX}" \
        --libdir="${LIBDIR}" \
        --build=i386-unknown-linux-musl \
        --host=i386-unknown-linux-musl \
        --disable-shared

    cat <<'MPARAM' > src/mparam.h
/*
SPDX-FileCopyrightText: 2005-2020 Free Software Foundation, Inc.
SPDX-License-Identifier: GPL-3.0-or-later
*/

/* This file is truncated version of src/mparam.h
*/

#ifndef __MPFR_IMPL_H__
# error "MPFR Internal not included"
#endif

#define MPFR_TUNE_CASE "default"

/****************************************************************
 * Default values of Threshold.                                 *
 * Must be included in any case: it checks, for every constant, *
 * if it has been defined, and it sets it to a default value if *
 * it was not previously defined.                               *
 ****************************************************************/
#include "generic/mparam.h"
MPARAM

    make MAKEINFO=true DESTDIR="${DESTDIR}"
    make MAKEINFO=true DESTDIR="${DESTDIR}" install

    cd /opt/build/
    sha256sum -o mpfr-4.1.0.answers /opt/build/musl-1.1.24/lib/pkgconfig/mpfr.pc
fi


if sha256sum -c mpc-1.2.1.answers
then
    echo mpc already built
else
    set -x
    gunzip -c /opt/build/mpc-1.2.1.tar.gz > /opt/build/mpc-1.2.1.tar
    tar -xf /opt/build/mpc-1.2.1.tar
    rm /opt/build/mpc-1.2.1.tar
    cd /opt/build/mpc-1.2.1

    export PREFIX=/
    export LIBDIR=/opt/build/musl-1.1.24/lib
    export LIBGCC2_INCLUDES='-I"/opt/build/musl-1.1.24/include" -I"/include"'
    export CPATH="/opt/build/musl-1.1.24/include:/include"
    export LIBRARY_PATH="/opt/build/musl-1.1.24/lib"
    export CC="i386-unknown-linux-musl-gcc"
    export CPP="i386-unknown-linux-musl-cpp"

    cp -f /opt/kaem/config.guess .
    cp -f /opt/kaem/config.sub .
    
    ./configure \
        --prefix="${PREFIX}" \
        --libdir="${LIBDIR}" \
        --host=i386-unknown-linux-musl \
        --build=i386-unknown-linux-musl \
        --disable-shared

    make MAKEINFO=true DESTDIR="${DESTDIR}"
    make MAKEINFO=true DESTDIR="${DESTDIR}" install

    cd /opt/build/
    sha256sum -o mpc-1.2.1.answers /opt/build/musl-1.1.24/lib/libmpc.a
fi
