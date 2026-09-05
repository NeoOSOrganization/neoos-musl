# Integration with NeoOS Ecosystem

## How neoos-musl Fits In

```
┌─────────────────────────────────────┐
│    neoos-kernel                     │
│  ├─ kernel/                         │
│  ├─ third_party/shim/               │ ← Syscall shim
│  └─ ...                             │
└────────────┬────────────────────────┘
             │ (provides shim)
             ▼
┌─────────────────────────────────────┐
│    neoos-musl                       │
│  ├─ upstream/     (musl source)     │
│  ├─ Makefile      (integrates shim) │
│  └─ build-output/ (output)          │
│      ├─ include/  (headers)         │
│      └─ lib/      (libc.a)          │
└────────────┬────────────────────────┘
             │ (provides lib + headers)
    ┌────────┴────────────────┬────────────────────┐
    ▼                         ▼                    ▼
neoos-kernel            neoos-3d-ascii-viewer  neoos-busybox
(userland)              (port)                 (port)
```

## Build Dependencies

Each layer depends on the layer below:

### neoos-kernel
- No musl dependency in core kernel
- But userland tests need musl for binary linking
- **Requirement:** musl must exist before `make test` works

### neoos-musl
- **Requires:** neoos-kernel (for shim at `../neoos-kernel/third_party/shim`)
- **Produces:** musl build artifacts for downstream use

### neoos-os-builder
- **Requires:** neoos-musl (to assemble OS image)
- Uses kernel + musl + ports as inputs

### Ports (neoos-busybox, neoos-3d-ascii-viewer, etc.)
- **Requires:** neoos-musl (to link against libc.a)
- Link command:
  ```makefile
  MUSL_DIR ?= ../neoos-musl/build-output
  LDFLAGS += -L$(MUSL_DIR)/lib -lc
  ```

## Integration Checklist

When setting up a clean environment:

- [ ] Clone neoos-kernel
  ```bash
  git clone https://github.com/NeoOSOrganization/neoos-kernel ../neoos-kernel
  ```

- [ ] Build kernel toolchain
  ```bash
  cd ../neoos-kernel
  ./toolchain/build.sh
  export PATH=$PWD/toolchain/x86_64-elf/bin:$PATH
  ```

- [ ] Clone neoos-musl
  ```bash
  git clone https://github.com/NeoOSOrganization/neoos-musl
  cd neoos-musl
  ```

- [ ] Initialize submodules
  ```bash
  git submodule update --init
  ```

- [ ] Build musl
  ```bash
  make
  ```

- [ ] Verify musl
  ```bash
  make verify
  ls -lh build-output/lib/libc.a
  ```

- [ ] Build kernel with external musl
  ```bash
  cd ../neoos-kernel
  make test MUSL_DIR=../neoos-musl/build-output
  ```

## Common Integration Issues

### Kernel build fails with "undefined reference to ..."
**Cause:** musl not built yet.

**Fix:**
```bash
cd neoos-musl
make
cd ../neoos-kernel
make test MUSL_DIR=../neoos-musl/build-output
```

### Shim integration failed in musl
**Cause:** Shim files not found or not compatible.

**Check:**
```bash
ls ../neoos-kernel/third_party/shim/
file ../neoos-kernel/third_party/shim/*.h
```

### Port linking fails against musl
**Cause:** MUSL_DIR not set or wrong path.

**Fix:**
```bash
make -C port MUSL_DIR=../neoos-musl/build-output
```

## Forward Compatibility

As neoos-kernel evolves:

1. **New syscalls:** Update shim in kernel repo
2. **Rebuild musl:** `make clean && make` (automatically re-integrates new shim)
3. **Ports pick up changes:** Rebuild ports with new musl
4. **Test:** Run kernel regression suite to verify all works together

No manual integration needed—the build system handles it.
