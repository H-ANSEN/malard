#!/bin/bash
# This script builds a cross compiler for the i686-elf target. The script 
# expects that all prerequisites to build GCC and Binutils are already 
# installed on the system.
#
# Resources:
# https://wiki.osdev.org/GCC_Cross-Compiler

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BINUTILS_VERSION=2.41
GCC_VERSION=12.2.0

PREFIX="$SCRIPT_DIR/i686-elf"
TARGET=i686-elf
PATH="$PREFIX/bin:$PATH"

log() {
    echo -e "\033[0;32m[INFO] $1\033[0m"
}

download_and_extract() {
    local url="$1"
    local filename=$(basename "$url")

    log "Downloading and extracting $filename"

    curl -O "$url"
    tar -xf "$filename"
}

build_binutils() {
    download_and_extract "https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.gz"

    mkdir binutils-build
    cd binutils-build

    log "Configuring Binutils..."
    ../binutils-$BINUTILS_VERSION/configure --target=$TARGET --prefix=$PREFIX --with-sysroot --disable-nls --disable-werror

    log "Building Binutils..."
    make -j$(nproc)
    make install

    cd ..
}

build_gcc() {
    download_and_extract "http://mirrors.concertpass.com/gcc/releases/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz"

    mkdir gcc-build
    cd gcc-build

    log "Configuring GCC..."
    ../gcc-$GCC_VERSION/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers

    log "Building GCC..."
    make -j$(nproc) all-gcc
    make -j$(nproc) all-target-libgcc

    log "Installing GCC..."
    make install-gcc
    make install-target-libgcc

    cd ..
}

build() {
    log "Building cross compiler for $TARGET"
    build_binutils
    build_gcc

    clean

    echo "export PATH=\"$PREFIX/bin:\$PATH\"" >> ~/.bashrc
    log "Cross compiler build complete!"
}

clean() {
    log "Cleaning up..."
    rm -rd binutils-$BINUTILS_VERSION
    rm -rd binutils-build
    rm -rd gcc-$GCC_VERSION
    rm -rd gcc-build
    rm -rf gcc-$GCC_VERSION.tar.gz 
    rm -rf binutils-$BINUTILS_VERSION.tar.gz
}

trap clean EXIT

build
