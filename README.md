obuild
======

Yet another automated gcc bootstrap from source, mostly for personal research.

This is largely based on the work done on https://github.com/fosslinux/live-bootstrap

The goal is to have a quick reproducible gcc bootstrap path that one single person can understand and run in reasonable time.

It builds from the tiny 640 bytes `kaem-optional-seed` up to gcc 4.0.4 with musl 1.1, mpfr, mpc, gmp and all requirements to run `musl-cross-make`.

---

Current version is the "barely working on my own machine messy prototype", missing the musl-cross-make integration. It takes about 30min to perform a full run on WSL2 (corei7, 16GB, `make` using only one core at the time).

What I want different from live-bootstrap:

 - No perl, no python, no scripts written in C. Just kaem and sh instrumentation.
 - No regen on yacc, autotools, bison, etc (we want to put it in but as optional).
 - No kernel, just toolchain and userland.
 - No particular GNU affinity (alternative, smaller libs welcome).
 - Low LOC count for the input sources.
 - stage0-posix `replace` instead of `simple-patch`

What I want to experiment but haven't yet:

 - Overall architecture definition (we're currently just 3 large unnamed messy scripts!)
   - stage0a.sh gets rid of the host
   - stage0b.kaem goes up to tcc-mes, bash, userland utils
   - kaem/stage1.sh goes up to gcc4, musl, expands userland
   - Maybe a step between 0b and 1 just for userland expansion? Isolate toolchain stuff.
   - Can we be functional (read .answer files and work with their sha's on paths) before sh?
 - Can tinyemu be used to cross bootstrap other architectures early?
 - Can we use sha256sum checksums to make the bootstrap functional?
 - Can we provide an option for chrootless builds?
 - Should we vendor musl-cross-make?
 - Can submodules be an alternative over tarballs? (user choice)
 - optional regen (how to manage divergent artifact checksums? What specific regens propagates artifact changes and to what extend?)
 - linux-like support (should run on WSL2, cygwin, linux emulators)
 - how to deliver artifacts for fast reproducibility check (which sha256sums matter for a given end artifact)?
 - Can I build tcc-win32 using existing tools only? How soon? Can that tcc go as far as building old mingw?

Also:

 - Using suckless's [9base](https://tools.suckless.org/9base/) instead of coreutils would simplify the build and drastically reduce input LOC. It would also preserve an important historical source.
 - Using [toybox](http://github.com/landley/toybox) instead of coreutils would simplify the build and drastically reduce input LOC. It would also acquire simple kernel building capabilities (mkroot). It has synergy with musl-cross-make, avoiding extra instrumentation.
 - Compiling [blink](https://github.com/jart/blink) from bootstrapped gcc 4.7.4 would break out of x86 confinement using a modern tool.

---

### Instructions

  1. `git submodule update --init --recursive`
  2. `sh -x stage0a.sh`

stage0a.sh will invoke stage0b.kaem automatically, stage0b.kaem will run kaem/stage1.sh automatically

You will need `sh`, `tar`, `mv`, `mkdir`, `env`, `wget` for the the first steps that
run on the host.

By the end, you should have a messy `/target` sysroot folder used in the build. No artifacts
are produced yet, but they can be extracted manually from the `/opt` tree.

For now, some libs are built out of their dir (other libs building /lib inside musl), this
is temporary.
            
### Thanks

This work would not be possible without [stage0-posix](https://github.com/oriansj/stage0-posix) and [live-bootstrap](https://github.com/fosslinux/live-bootstrap).

