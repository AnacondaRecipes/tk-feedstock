#!/bin/bash

IFS="." read -a VER_ARR <<<"${PKG_VERSION}"

ARCH_FLAG=""
if [[ ${ARCH} == 64 || ${ARCH} == s390x ]]; then
    ARCH_FLAG="--enable-64bit"
fi

# configure checks for zip
ln -s ${PREFIX}/bin/minizip ${PREFIX}/bin/zip

pushd tcl${PKG_VERSION}/unix

case "${target_platform}" in
osx-*)
    # An exported DYLD_* won't get inherited by SIP protected
    # binaries: /usr/bin/env, /bin/bash, ...
    export DYLD_FALLBACK_LIBRARY_PATH=${PWD}${DYLD_FALLBACK_LIBRARY_PATH:+:$DYLD_FALLBACK_LIBRARY_PATH}

    # configure: error: .../bin/tclsh is not a Tcl 9 tclsh.
    export TCLSH_NATIVE=$(type -p tclsh)
    ;;
*)
    export LD_LIBRARY_PATH=${PWD}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    ;;
esac

# checking for tclsh... /home/rocky/.conda/envs/build/bin/tclsh
PATH=$PATH:$PWD

  # autoreconf -vfi
  ./configure  --prefix="${PREFIX}"  \
               --host=${HOST}        \
               ${ARCH_FLAG}
  make -j${CPU_COUNT} ${VERBOSE_AT}
  make install install-private-headers
popd

pushd tk${PKG_VERSION}/unix
  # autoreconf -vfi
  ./configure --prefix="${PREFIX}"        \
              --host=${HOST}              \
              --with-tcl="${PREFIX}"/lib  \
              --enable-aqua=yes           \
              ${ARCH_FLAG}
  make -j${CPU_COUNT} ${VERBOSE_AT}
  make install
popd

rm -rf "${PREFIX}"/{man,share}

# Link binaries to non-versioned names to make them easier to find and use.
ln -s "${PREFIX}"/bin/tclsh${VER_ARR[0]}.${VER_ARR[1]} "${PREFIX}"/bin/tclsh
ln -s "${PREFIX}"/bin/wish${VER_ARR[0]}.${VER_ARR[1]} "${PREFIX}"/bin/wish

# copy headers
cp "${SRC_DIR}"/tk${PKG_VERSION}/{unix,macosx,generic}/*.h "${PREFIX}"/include/
