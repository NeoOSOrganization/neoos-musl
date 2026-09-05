# Version Tracking

## How Versions Are Managed

NeoOS musl build depends on three version sources:

### 1. Musl Upstream (git submodule)
**File:** `.gitmodules` and `upstream/`

The musl source is pinned to a specific commit via git submodule.

```bash
# Check current musl version:
cd upstream
git log --oneline | head -1
git describe --tags || git rev-parse --short HEAD

# To update musl to latest:
git submodule update --remote upstream
git commit -am "build: update musl to latest"
```

### 2. NeoOS Kernel Shim
**Location:** `../neoos-kernel/third_party/shim/`

The syscall shim comes from the kernel repo. Both repos should track compatible versions.

```bash
# Check shim version (in kernel repo):
cd ../neoos-kernel
git log --oneline third_party/shim/ | head -1

# Compatibility:
# - If kernel shim changes significantly, rebuild musl
# - Always use same kernel/musl version together
```

### 3. Cross-Compiler Version
**Requirement:** x86_64-elf-gcc (from kernel toolchain)

The build uses whatever cross-compiler is in PATH.

```bash
# Check compiler version:
x86_64-elf-gcc --version

# All systems building musl should use same toolchain version
# The kernel repo provides the toolchain via ./toolchain/build.sh
```

## Reproducible Builds

To ensure reproducible builds across machines:

1. **Pin musl commit** (via submodule)
   ```bash
   git submodule status upstream
   # Example: 1234567890abcdef1234567890abcdef12345678 upstream
   ```

2. **Use same kernel shim**
   ```bash
   cd ../neoos-kernel
   git log --oneline third_party/shim/ | head -1
   ```

3. **Use same cross-compiler**
   ```bash
   x86_64-elf-gcc --version
   ```

## Version Mismatch Symptoms

If builds diverge between machines:

- Different musl versions
  ```bash
  cd upstream && git status
  # If "dirty", musl was modified locally - avoid this
  ```

- Different kernel shim
  ```bash
  diff ../neoos-kernel/third_party/shim/*.h ncurses-shim/ || echo "Not in musl repo"
  ```

- Different compiler flags
  ```bash
  # Check Makefile for CFLAGS
  grep CFLAGS Makefile
  grep CFLAGS build.sh
  ```

## Release Procedure

When releasing a new version:

1. Update musl to desired commit
   ```bash
   cd upstream
   git fetch
   git checkout v1.2.6  # or specific commit
   cd ..
   ```

2. Tag the release
   ```bash
   git tag -a neoos-musl-v1.0.0 -m "musl 1.2.6 with NeoOS shim"
   git push origin neoos-musl-v1.0.0
   ```

3. Document what changed
   - Musl version
   - Shim version
   - Compiler version used
   - Any build flag changes
