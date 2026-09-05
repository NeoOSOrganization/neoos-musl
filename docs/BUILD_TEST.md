# Standalone Build Test

## Purpose

Verify that neoos-musl can be built independently without the full monorepo.

## Prerequisites

- neoos-kernel cloned to `../neoos-kernel`
- neoos-kernel toolchain built: `../neoos-kernel/toolchain/build.sh`
- Cross-compiler in PATH: `export PATH=$(pwd)/../neoos-kernel/toolchain/x86_64-elf/bin:$PATH`
- Git submodule support

## Test Steps

### Step 1: Clone and Initialize
```bash
# From a clean directory
git clone https://github.com/NeoOSOrganization/neoos-kernel ../neoos-kernel
git clone https://github.com/NeoOSOrganization/neoos-musl
cd neoos-musl

# Initialize upstream submodule
git submodule update --init
```

**Expected Output:**
```
Cloning into upstream...
Submodule path upstream: checked out <commit-hash>
```

### Step 2: Build Toolchain
```bash
cd ../neoos-kernel
./toolchain/build.sh
export PATH=$(pwd)/toolchain/x86_64-elf/bin:$PATH
cd ../neoos-musl
```

**Expected Output:**
```
Building cross-compiler toolchain...
[... build progress ...]
Toolchain built at ./toolchain/x86_64-elf/
```

### Step 3: Verify Shim Exists
```bash
ls ../neoos-kernel/third_party/shim/
```

**Expected Output:**
```
arch.c  bits.h  pthread.h  pthread_arch.h  atomic_arch.h  ...
```

### Step 4: Build Musl
```bash
make
```

**Expected Output:**
```
Building musl with NeoOS shim...
  Kernel shim: ../neoos-kernel/third_party/shim
  Output: build-output

Configuring musl...
[... configure output ...]

Integrating NeoOS syscall shim...
  ✓ Shim integrated into arch/x86_64/bits/

Building musl...
  ✓ Build complete

Installing musl to build-output...
  ✓ Install complete

✓ musl built successfully at build-output
-rw-r--r-- 1 user group 1.2M build-output/lib/libc.a
```

### Step 5: Verify Output
```bash
make verify
```

**Expected Output:**
```
✓ libc.a built: 1.2M
✓ Shim integrated in syscall.h
```

### Step 6: Check Shim Integration
```bash
grep -c "NeoOS\|syscall" build-output/include/sys/syscall.h
# Should be > 0
```

**Expected Output:**
```
42
```

## Test Success Criteria

✓ All steps complete without errors
✓ build-output/lib/libc.a exists and is > 1MB
✓ build-output/include/ has musl headers
✓ Syscall shim is integrated (grep finds syscall definitions)
✓ No undefined references in libc.a

## Build Time Expectations

- Toolchain build: 5-10 minutes (first time only)
- musl configure: 1-2 minutes
- musl build: 2-3 minutes
- **Total:** ~10 minutes first run, ~5 minutes subsequent

## Common Failures and Fixes

### "x86_64-elf-gcc: command not found"
Export PATH to toolchain:
```bash
export PATH=../neoos-kernel/toolchain/x86_64-elf/bin:$PATH
```

### "Kernel shim not found"
Verify neoos-kernel is cloned:
```bash
ls ../neoos-kernel/third_party/shim/
```

### "upstream submodule not initialized"
Initialize it:
```bash
git submodule update --init
```

### Build hangs
musl configure can take time. Wait up to 3 minutes. If longer, press Ctrl+C and check:
```bash
tail upstream/config.log
```

## Next: Automated Testing

For CI/CD, this test can be:
1. Automated via GitHub Actions
2. Run on each PR
3. Cached to speed up (git submodules, toolchain)
4. Validated against success criteria

See GITHUB_ACTIONS.md (Phase 3) for automation.
