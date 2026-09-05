#!/bin/bash
set -e

KERNEL_SHIM_DIR="${KERNEL_SHIM_DIR:-../neoos-kernel/third_party/shim}"
PREFIX="${PREFIX:-build-output}"
UPSTREAM_DIR="${UPSTREAM_DIR:-upstream}"

if [ ! -d "$KERNEL_SHIM_DIR" ]; then
    echo "Error: Kernel shim not found at $KERNEL_SHIM_DIR"
    exit 1
fi

if [ ! -d "$UPSTREAM_DIR" ]; then
    echo "Error: Upstream musl not found at $UPSTREAM_DIR"
    exit 1
fi

echo "Building musl with NeoOS shim..."
mkdir -p "$PREFIX"

echo "Integrating NeoOS syscall shim..."
MUSL_DIR="$(cd "$UPSTREAM_DIR" && pwd)" "$KERNEL_SHIM_DIR/apply.sh"

cd "$UPSTREAM_DIR"

if [ ! -f "configure" ]; then
    echo "Error: musl configure script not found"
    exit 1
fi

echo "Configuring musl..."
./configure \
    --prefix="$(cd .. && pwd)/$PREFIX" \
    --target=x86_64 \
    --disable-shared \
    CC="${CC:-x86_64-elf-gcc}" \
    AR="${AR:-x86_64-elf-ar}" \
    RANLIB="${RANLIB:-x86_64-elf-ranlib}" \
    CFLAGS="-mcmodel=large -fno-pic -mno-red-zone -O2" 2>&1 | tail -5

echo "Building musl..."
make -j"$(nproc)"
echo "  OK Build complete"

echo "Installing musl to $PREFIX..."
make install
echo "  OK Install complete"

cd ..

if [ -f "$PREFIX/lib/libc.a" ]; then
    echo ""
    echo "OK musl built successfully at $PREFIX"
    ls -lh "$PREFIX/lib/libc.a"
else
    echo "ERROR Build failed: libc.a not found"
    exit 1
fi