### ZLIB ###
_build_zlib() {
local VERSION="1.3.1"
local FOLDER="zlib-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://zlib.net/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --prefix="${DEPS}" --libdir="${DEST}/lib" --shared
make
make install
rm -v "${DEST}/lib"/*.a
popd
}

### BZIP ###
_build_bzip() {
local VERSION="1.0.8"
local FOLDER="bzip2-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://sourceware.org/pub/bzip2/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
sed -i -e "s/all: libbz2.a bzip2 bzip2recover test/all: libbz2.a bzip2 bzip2recover/" Makefile
make -f Makefile-libbz2_so CC="${CC}" AR="${AR}" RANLIB="${RANLIB}" CFLAGS="${CFLAGS} -fpic -fPIC -Wall -D_FILE_OFFSET_BITS=64"
ln -s libbz2.so.1.0.8 libbz2.so
cp -avR *.h "${DEPS}/include/"
cp -avR *.so* "${DEST}/lib/"
popd
}

### OPENSSL ###
_build_openssl() {
local VERSION="1.1.1zb_p3"
local FOLDER="${VERSION}"
local FILE="${FOLDER}.tar.gz"
# local URL="http://www.openssl.org/source/${FILE}"
local URL="https://github.com/kzalewski/openssl-1.1.1/archive/refs/tags/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/openssl-1.1.1-1.1.1zb_p3"
mkdir ${DEST}/etc
mkdir ${DEST}/etc/ssl
./Configure --prefix="${DEPS}" --openssldir="${DEST}/etc/ssl" \
  zlib-dynamic --with-zlib-include="${DEPS}/include" --with-zlib-lib="${DEPS}/include" \
  shared threads linux-armv4 -DL_ENDIAN ${CFLAGS} ${LDFLAGS} \
  -Wa,--noexecstack -Wl,-z,noexecstack
sed -i -e "s/-O3//g" Makefile
make
make install_sw
mkdir -p "${DEST}/libexec"
cp -vfa "${DEPS}/bin/openssl" "${DEST}/libexec/"
cp -vfa "${DEPS}/lib/libssl.so"* "${DEST}/lib/"
cp -vfa "${DEPS}/lib/libcrypto.so"* "${DEST}/lib/"
cp -vfaR "${DEPS}/lib/engines"* "${DEST}/lib/"
cp -vfaR "${DEPS}/lib/pkgconfig" "${DEST}/lib/"
rm -vf "${DEPS}/lib/libcrypto.a" "${DEPS}/lib/libssl.a"
sed -e "s|^libdir=.*|libdir=${DEST}/lib|g" -i "${DEST}/lib/pkgconfig/libcrypto.pc"
sed -e "s|^libdir=.*|libdir=${DEST}/lib|g" -i "${DEST}/lib/pkgconfig/libssl.pc"
popd
}

### NCURSES ###
_build_ncurses() {
local VERSION="6.0"
local FOLDER="ncurses-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://ftp.gnu.org/gnu/ncurses/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --libdir="${DEST}/lib" --datadir="${DEST}/share" --with-shared --enable-rpath
make
make install
rm -v "${DEST}/lib"/*.a
popd
}

### SQLITE ###
_build_sqlite() {
#local VERSION="3410000"
local VERSION="3490100"
local FOLDER="sqlite-autoconf-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://sqlite.org/$(date +%Y)/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --libdir="${DEST}/lib" --disable-static
make
make install
popd
}

### BDB ###
#_build_bdb() {
#local VERSION="6.1.26"
#local FOLDER="db-${VERSION}"
#local FILE="${FOLDER}.tar.gz"
#local URL="http://download.oracle.com/berkeley-db/${FILE}"

#_download_tgz "${FILE}" "${URL}" "${FOLDER}"
#pushd "target/${FOLDER}/build_unix"
#../dist/configure --host="${HOST}" --prefix="${DEPS}" --libdir="${DEST}/lib" --disable-static --enable-compat185 --enable-dbm
#make
#make install
#popd
#}

### BDB ###
_build_bdb() {
local VERSION="18.1.40"
local FOLDER="db-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://download.oracle.com/berkeley-db/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}/build_unix"
../dist/configure --host="${HOST}" --prefix="${DEPS}" \
  --libdir="${DEST}/lib" --disable-static \
  --enable-compat185 --enable-dbm
make
make install
popd
}


### LIBFFI ###
_build_libffi() {
local VERSION="3.4.3"
local FOLDER="libffi-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="ftp://sourceware.org/pub/libffi/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --libdir="${DEST}/lib" --disable-static
make
make install
# mkdir -p "${DEPS}/include/"
# cp -v "${DEST}/lib/${FOLDER}/include"/* "${DEPS}/include/"
popd
}

### EXPAT ###
_build_expat() {
local VERSION="2.7.1"
local FOLDER="expat-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://sourceforge.net/projects/expat/files/expat/${VERSION}/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --libdir="${DEST}/lib" --disable-static
make
make install
popd
}

### PYTHON2 ###
#_build_python() {
#local VERSION="2.7.18"
#local FOLDER="Python-${VERSION}"
#local FILE="${FOLDER}.tgz"
#local URL="https://www.python.org/ftp/python/${VERSION}/${FILE}"

#_download_tgz "${FILE}" "${URL}" "${FOLDER}"

#if [ -d "target/${FOLDER}-native" ]; then
#  rm -fvR "target/${FOLDER}-native"
#fi
#cp -avR "target/${FOLDER}" "target/${FOLDER}-native"
#( source uncrosscompile.sh
#  pushd "target/${FOLDER}-native"
#  ./configure
#  make )

#pushd "target/${FOLDER}"
#export _PYTHON_HOST_PLATFORM="linux-armv7l"
#rm -fvR Modules/_ctypes/libffi*
#./configure --host="${HOST}" --build="$(uname -p)" --prefix="${DEST}" --mandir="${DEST}/man" --enable-shared --enable-ipv6 --enable-unicode --with-system-ffi --with-system-expat --with-dbmliborder=bdb:gdbm:ndbm \
#  PYTHON_FOR_BUILD="_PYTHON_PROJECT_BASE=${PWD} _PYTHON_HOST_PLATFORM=${_PYTHON_HOST_PLATFORM} PYTHONPATH=${PWD}/build/lib.${_PYTHON_HOST_PLATFORM}-2.7:${PWD}/Lib:${PWD}/Lib/plat-linux2 ${PWD}/../${FOLDER}-native/python" \
#  CPPFLAGS="${CPPFLAGS} -I${DEPS}/include/ncurses" LDFLAGS="${LDFLAGS} -L${PWD}"\
#  ac_cv_have_long_long_format=yes ac_cv_buggy_getaddrinfo=no ac_cv_file__dev_ptmx=yes ac_cv_file__dev_ptc=no
#make || true
#cp -v "../${FOLDER}-native/Parser/pgen" Parser/pgen
#make
#cp -av "${PWD}/build/lib.${_PYTHON_HOST_PLATFORM}-2.7/"_sysconfigdata.* "${PWD}/build/"
#make install PYTHON_FOR_BUILD="_PYTHON_PROJECT_BASE=${PWD} _PYTHON_HOST_PLATFORM=${_PYTHON_HOST_PLATFORM} PYTHONPATH=${PWD}/build ${PWD}/../${FOLDER}-native/python"
#popd
#}

### PYTHON3 ###
_build_python() {
local VERSION="3.14.0"
local FOLDER="Python-${VERSION}"
local FILE="${FOLDER}.tgz"
local URL="https://www.python.org/ftp/python/${VERSION}/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"

if [ -d "target/${FOLDER}-native" ]; then
  rm -fvR "target/${FOLDER}-native"
fi
cp -avR "target/${FOLDER}" "target/${FOLDER}-native"
( source uncrosscompile.sh
  pushd "target/${FOLDER}-native"
  ./configure
  make )

pushd "target/${FOLDER}"
export _PYTHON_HOST_PLATFORM="linux-armv7l"
rm -fvR Modules/_ctypes/libffi*
./configure --host="${HOST}" --build="$(uname -p)" --prefix="${DEST}" --mandir="${DEST}/man" --enable-shared --enable-ipv6 --enable-unicode --with-system-ffi --with-system-expat --with-dbmliborder=bdb:gdbm:ndbm \
  PYTHON_FOR_BUILD="_PYTHON_PROJECT_BASE=${PWD} _PYTHON_HOST_PLATFORM=${_PYTHON_HOST_PLATFORM} PYTHONPATH=${PWD}/build/lib.${_PYTHON_HOST_PLATFORM}-3.14:${PWD}/Lib:${PWD}/Lib/plat-linux2 ${PWD}/../${FOLDER}-native/python" \
  CPPFLAGS="${CPPFLAGS} -I${DEPS}/include/ncurses" LDFLAGS="${LDFLAGS} -L${PWD}"\
  ac_cv_have_long_long_format=yes ac_cv_buggy_getaddrinfo=no ac_cv_file__dev_ptmx=yes ac_cv_file__dev_ptc=no
make || true
cp -v "../${FOLDER}-native/Parser/pgen" Parser/pgen
make
cp -av "${PWD}/build/lib.${_PYTHON_HOST_PLATFORM}-3.14/"_sysconfigdata.* "${PWD}/build/"
make install PYTHON_FOR_BUILD="_PYTHON_PROJECT_BASE=${PWD} _PYTHON_HOST_PLATFORM=${_PYTHON_HOST_PLATFORM} PYTHONPATH=${PWD}/build ${PWD}/../${FOLDER}-native/python"
popd
}


### SETUPTOOLS ###
_build_setuptools() {
# setup qemu static for this one:
# https://wiki.debian.org/QemuUserEmulation
# apt-get install binfmt-support qemu-user-static
# http://nairobi-embedded.org/qemu_usermode.html#qemu_ld_prefix
# export QEMU_LD_PREFIX="${HOME}/xtools/toolchain/${DROBO}/${HOST}/libc"

local VERSION="79.0.0"
local FOLDER="setuptools-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://github.com/pypa/setuptools/archive/refs/tags/v${VERSION}.tar.gz"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
sed -e "21i${DEST}/etc/ssl/certs/ca-certificates.crt" \
    -e "21,26d" \
    -i setuptools/ssl_support.py
QEMU_LD_PREFIX="${HOME}/xtools/toolchain/${DROBO}/${HOST}/libc" \
  PYTHONPATH="${DEST}/lib/python3.14/site-packages" "${DEST}/bin/python" setup.py \
  build --executable="${DEST}/bin/python3.14" \
  install --prefix="${DEST}" --force
for f in {easy_install,easy_install-3.14}; do
  sed -i -e "1 s|^.*$|#!${DEST}/bin/python3.14|g" "${DEST}/bin/$f"
done
popd
}

### PIP ###
_build_pip() {
# setup qemu static for this one:
# https://wiki.debian.org/QemuUserEmulation
# apt-get install binfmt-support qemu-user-static
# http://nairobi-embedded.org/qemu_usermode.html#qemu_ld_prefix
# export QEMU_LD_PREFIX="${HOME}/xtools/toolchain/${DROBO}/${HOST}/libc"

local VERSION="25.0.1"
local FOLDER="pip-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://pypi.python.org/packages/source/p/pip/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
QEMU_LD_PREFIX="${HOME}/xtools/toolchain/${DROBO}/${HOST}/libc" \
  PYTHONPATH="${DEST}/lib/python3.14/site-packages" "${DEST}/bin/python" setup.py \
  build --executable="${DEST}/bin/python3.14" \
  install --prefix="${DEST}" --force
for f in {pip,pip2,pip3.14}; do
  sed -i -e "1 s|^.*$|#!${DEST}/bin/python3.14|g" "${DEST}/bin/$f"
done
popd
}

### CERTIFICATES ###
_build_certificates() {
# update CA certificates on a Debian/Ubuntu machine:
#sudo update-ca-certificates
cp -vf /etc/ssl/certs/ca-certificates.crt "${DEST}/etc/ssl/certs/"
ln -vfs certs/ca-certificates.crt "${DEST}/etc/ssl/cert.pem"
}

### BUILD ###
_build() {
  _build_zlib
  _build_bzip
  _build_openssl
  _build_ncurses
  _build_sqlite
  _build_bdb
  _build_libffi
  _build_expat
  _build_python
  _build_setuptools
  _build_pip
  _build_certificates
  _package
}
