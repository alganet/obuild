#!/usr/bin/env sh

set -eufx

WGET="${WGET:-$(command -v wget)}"
TAR="${TAR:-$(command -v tar)}"
MV="${MV:-$(command -v mv)}"
MKDIR="${MKDIR:-$(command -v mkdir)}"
ENV="${ENV:-$(command -v env)}"

PATH=""

$MKDIR -p target/bin
$MKDIR -p target/opt/build
$MKDIR -p target/opt/kaem/bash
$MKDIR -p target/opt/kaem/musl
$MKDIR -p target/opt/kaem/coreutils
$MKDIR -p target/opt/kaem/tcc
$MKDIR -p target/opt/kaem/binutils
$MKDIR -p target/opt/kaem/gzip

m () {
    set -- "$1" "${1##*/}"
    test -f "target/opt/build/${2}" || $WGET "https://${1}" -O "target/opt/build/${2}"
}

m "mirrors.kernel.org/gnu/mes/mes-0.26.tar.gz"
m "github.com/Googulator/nyacc/releases/download/V1.00.2-lb1/nyacc-1.00.2-lb1.tar.gz"
m "lilypond.org/janneke/tcc/tcc-0.9.26-1147-gee75a10c.tar.gz"
m "www.mirrorservice.org/sites/download.savannah.gnu.org/releases/tinycc/tcc-0.9.27.tar.bz2"
m "mirrors.kernel.org/gnu/make/make-3.82.tar.bz2"
m "mirrors.kernel.org/gnu/patch/patch-2.5.9.tar.gz"
m "src.fedoraproject.org/repo/pkgs/bash/bash-2.05b.tar.bz2/f3e5428ed52a4f536f571a945d5de95d/bash-2.05b.tar.bz2"
m "musl.libc.org/releases/musl-1.1.24.tar.gz"
m "mirrors.kernel.org/gnu/sed/sed-4.0.9.tar.gz"
m "mirrors.kernel.org/gnu/coreutils/coreutils-5.0.tar.bz2"
m "mirrors.kernel.org/gnu/binutils/binutils-2.30.tar.gz"
m "mirrors.kernel.org/gnu/tar/tar-1.12.tar.gz"
m "mirrors.kernel.org/gnu/gzip/gzip-1.2.4.tar.gz"
m "ixpeering.dl.sourceforge.net/project/lzmautils/xz-5.4.1.tar.bz2"
m "mirrors.kernel.org/gnu/grep/grep-2.4.tar.gz"
m "mirrors.kernel.org/gnu/gawk/gawk-3.0.4.tar.gz"
m "mirrors.kernel.org/gnu/coreutils/coreutils-6.10.tar.lzma"
m "mirrors.kernel.org/gnu/diffutils/diffutils-2.7.tar.gz"

#m "github.com/oriansj/stage0-posix/releases/download/Release_1.6.0/stage0-posix-1.6.0.tar.gz"
# if ! test -d stage0-posix
# then
#     $TAR -xf target/opt/build/stage0-posix-1.6.0.tar.gz
#     $MV stage0-posix-1.6.0 stage0-posix
# fi

cd stage0-posix
if ! test -e ./x86/bin/sha256sum || ! ./x86/bin/sha256sum -c x86.answers
then 
    $ENV -i ./bootstrap-seeds/POSIX/x86/kaem-optional-seed

    ./x86/bin/cp ./x86/bin/cp ../target/bin
    ./x86/bin/cp ./x86/bin/chmod ../target/bin
    ./x86/bin/chmod 755 ../target/bin/chmod
    ../target/bin/chmod 755 ../target/bin/cp

    cd ../target

    for tool in blood-elf catm get_machine hex2 kaem \
        M1 M2-Mesoplanet M2-Planet match mkdir replace rm \
        sha256sum unbz2 ungz untar unxz wrap
    do
        ./bin/cp ../stage0-posix/x86/bin/$tool ./bin
        ./bin/chmod 755 ./bin/$tool
    done
    unset tool
fi

cd ../target
./bin/cp ../stage0b.kaem ./kaem.run


./bin/cp ../kaem/config.sub ./opt/kaem/config.sub
./bin/cp ../kaem/config.guess ./opt/kaem/config.guess

./bin/cp ../kaem/stage1.sh ./opt/kaem/stage1.sh
./bin/cp ../kaem/noop.kaem ./opt/kaem/noop.kaem
./bin/cp ../kaem/patch.Makefile ./opt/kaem/patch.Makefile
./bin/cp ../kaem/bash/builtins.mk ./opt/kaem/bash/
./bin/cp ../kaem/bash/common.mk ./opt/kaem/bash/
./bin/cp ../kaem/bash/dev-tty.patch ./opt/kaem/bash/
./bin/cp ../kaem/bash/extern.patch ./opt/kaem/bash/
./bin/cp ../kaem/bash/locale.patch ./opt/kaem/bash/
./bin/cp ../kaem/bash/main.mk ./opt/kaem/bash/
./bin/cp ../kaem/bash/mes-libc.patch ./opt/kaem/bash/
./bin/cp ../kaem/bash/missing-defines.patch ./opt/kaem/bash/
./bin/cp ../kaem/bash/size.patch ./opt/kaem/bash/
./bin/cp ../kaem/bash/tinycc.patch ./opt/kaem/bash/

./bin/cp ../kaem/musl/avoid_sys_clone.patch ./opt/kaem/musl/
./bin/cp ../kaem/musl/madvise_preserve_errno.patch ./opt/kaem/musl/
./bin/cp ../kaem/musl/avoid_set_thread_area.patch ./opt/kaem/musl/
./bin/cp ../kaem/musl/fenv.patch ./opt/kaem/musl/
./bin/cp ../kaem/musl/va_list.patch ./opt/kaem/musl/
./bin/cp ../kaem/musl/set_thread_area.patch ./opt/kaem/musl/
./bin/cp ../kaem/musl/makefile.patch ./opt/kaem/musl/
./bin/cp ../kaem/musl/sigsetjmp.patch ./opt/kaem/musl/

./bin/cp ../kaem/coreutils/modechange.patch ./opt/kaem/coreutils/
./bin/cp ../kaem/coreutils/mbstate.patch ./opt/kaem/coreutils/
./bin/cp ../kaem/coreutils/expr-strcmp.patch ./opt/kaem/coreutils/
./bin/cp ../kaem/coreutils/sort-locale.patch ./opt/kaem/coreutils/
./bin/cp ../kaem/coreutils/touch-getdate.patch ./opt/kaem/coreutils/
./bin/cp ../kaem/coreutils/ls-strcmp.patch ./opt/kaem/coreutils/
./bin/cp ../kaem/coreutils/tac-uint64.patch ./opt/kaem/coreutils/

./bin/cp ../kaem/tcc/dont-skip-weak-symbols-ar.patch ./opt/kaem/tcc/
./bin/cp ../kaem/tcc/ignore-static-inside-array.patch ./opt/kaem/tcc/
./bin/cp ../kaem/tcc/static-link.patch ./opt/kaem/tcc/

./bin/cp ../kaem/binutils/libiberty-add-missing-config-directory-reference.patch ./opt/kaem/binutils/
./bin/cp ../kaem/binutils/new-gettext.patch ./opt/kaem/binutils/
./bin/cp ../kaem/binutils/opcodes-ensure-i386-init-dependencies-are-satisfied.patch ./opt/kaem/binutils/

./bin/cp ../kaem/gzip/makecrc-write-to-file.patch ./opt/kaem/gzip/
./bin/cp ../kaem/gzip/removecrc.patch ./opt/kaem/gzip/



exec ./bin/wrap ./bin/kaem --verbose --init-mode --warn --strict --file kaem.run

