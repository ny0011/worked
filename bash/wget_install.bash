#!/bin/bash

pkg_arr=(
'https://ftp.gnu.org/gnu/m4/m4-1.4.16.tar.gz' 
'https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz' 
'https://ftp.gnu.org/gnu/nettle/nettle-3.4.tar.gz' 
'https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.13.tar.gz'    
'https://ftp.gnu.org/gnu/libunistring/libunistring-0.9.8.tar.xz'
'https://github.com/libffi/libffi/releases/download/v3.4.2/libffi-3.4.2.tar.gz'
'https://pkgconfig.freedesktop.org/releases/pkg-config-0.23.tar.gz'
'https://github.com/p11-glue/p11-kit/releases/download/0.23.9/p11-kit-0.23.9.tar.gz'
'https://www.gnupg.org/ftp/gcrypt/gnutls/v3.6/gnutls-3.6.2.tar.xz'
'http://mirror.yongbok.net/gnu/wget/wget-1.19.4.tar.gz' )

for pkg_uri in "${pkg_arr[@]}"; do
    pkg_name="${pkg_uri##*/}"
    echo "Downloading ${pkg_name}"
    wget --no-check-certificate "${pkg_uri}"
    tar -xvf ${pkg_name} 1> /dev/null
    cd ${pkg_name%%.tar.*} || exit 0
    ./configure 1> /dev/null && ( make 1> /dev/null && make install 1> /dev/null ) || exit 0
    cd ..
done

rm -f !(wget_install.bash)
