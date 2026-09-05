# Building musl with NeoOS Shim

## Prerequisites

- neoos-kernel repository (for the shim)
- x86_64-elf cross-compiler
- Standard build tools (make, autoconf, etc.)

## Build

```bash
make KERNEL_SHIM_DIR=../neoos-kernel/third_party/shim
```

### Environment Variables

- `KERNEL_SHIM_DIR`: Path to the NeoOS shim (default: `../neoos-kernel/third_party/shim`)
- `PREFIX`: Installation prefix (default: `build-output`)

## Output

After build:
- `build-output/include/` — musl headers with integrated NeoOS shim
- `build-output/lib/libc.a` — static library ready to link

## Verify

Check that the shim is integrated:

```bash
grep -l "NeoOS" build-output/include/sys/syscall.h
# Should find NeoOS references in syscall.h
```

## Clean

```bash
make clean  # Removes build-output/
```
