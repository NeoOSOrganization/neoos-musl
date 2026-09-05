# NeoOS musl libc

musl libc (1.2.5) compiled with NeoOS syscall shim integration.

## Quick Start

Build musl (requires neoos-kernel repo for the shim):

```sh
git clone https://github.com/NeoOSOrganization/neoos-kernel ../neoos-kernel
make KERNEL_SHIM_DIR=../neoos-kernel/third_party/shim
# Produces: build-output/include/ and build-output/lib/libc.a
```

## How It Works

The NeoOS shim (in neoos-kernel) translates Linux syscall numbers to NeoOS syscall numbers. This repo:

1. Clones the kernel repo to get the shim
2. Integrates the shim into musl's arch directory during build
3. Compiles musl with the integrated shim
4. Produces headers and static library for kernel and ports to link against

## Integration

Kernel and ports link against the compiled musl:

```makefile
MUSL_DIR ?= ../neoos-musl/build-output

CFLAGS += -I$(MUSL_DIR)/include
LDFLAGS += -L$(MUSL_DIR)/lib -lc
```

## Documentation

- **Build options:** See `BUILD.md`
- **Architecture:** See the spec at https://github.com/NeoOSOrganization/neoos-docs

## License

musl is MIT licensed. NeoOS shim integration is under the same license as NeoOS kernel.

## In This Organization

- **[neoos-kernel](https://github.com/NeoOSOrganization/neoos-kernel)** — Kernel that uses this libc
- **[neoos-os-builder](https://github.com/NeoOSOrganization/neoos-os-builder)** — OS image builder (uses kernel + musl + ports)
- **[neoos-docs](https://github.com/NeoOSOrganization/neoos-docs)** — Full documentation
