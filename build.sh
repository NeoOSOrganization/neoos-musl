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

cd "$UPSTREAM_DIR"

if [ ! -f "configure" ]; then
    echo "Error: musl configure script not found"
    exit 1
fi

echo "Configuring musl..."
./configure \
    --prefix="$(cd .. && pwd)/$PREFIX" \
    --target=x86_64-elf \
    --disable-shared \
    --enable-static \
    CC=x86_64-elf-gcc \
    CFLAGS="-O2 -march=x86-64" 2>&1 | tail -5

echo "Integrating NeoOS syscall shim..."
if [ -d "$KERNEL_SHIM_DIR" ]; then
    cp "$KERNEL_SHIM_DIR"/*.h arch/x86_64/bits/ 2>/dev/null || true
    echo "  OK Shim integrated into arch/x86_64/bits/"
fi

echo "Building musl..."
make -j4
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