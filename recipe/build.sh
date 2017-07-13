#!/bin/bash

IFS='.' read -a VER_ARR <<< ${PKG_VERSION}

ARCH_FLAG=""
if [[ ${ARCH} == 64 ]]; then
    ARCH_FLAG="--enable-64bit"
fi

cd $SRC_DIR/tcl${VER}/unix
./configure \
	--prefix="${PREFIX}" \
	$ARCH_FLAG \

make
make install

cd $SRC_DIR/tk${VER}/unix
./configure \
	--prefix="${PREFIX}" \
	$ARCH_FLAG \
	--with-tcl="${PREFIX}/lib" \
	--enable-aqua=yes \

make
make install

cd $PREFIX
rm -rf man share

# Link binaries to non-versioned names to make them easier to find and use.
ln -s "${PREFIX}"/bin/tclsh${VER_ARR[0]}.${VER_ARR[1]} "${PREFIX}"/bin/tclsh
ln -s "${PREFIX}"/bin/wish${VER_ARR[0]}.${VER_ARR[1]} "${PREFIX}"/bin/wish

# copy headers
cp "${SRC_DIR}"/tk${PKG_VERSION}/{unix,generic}/*.h "${PREFIX}"/include/
