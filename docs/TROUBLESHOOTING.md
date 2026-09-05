# Build Troubleshooting

## "Kernel shim not found at ../neoos-kernel/third_party/shim"

**Cause:** neoos-kernel repo has not been cloned yet.

**Solution:**
```bash
# From the parent directory of neoos-musl:
git clone https://github.com/NeoOSOrganization/neoos-kernel ../neoos-kernel

# Then try building again:
cd neoos-musl
make
```

## "x86_64-elf-gcc: command not found"

**Cause:** Cross-compiler toolchain is not built or not in PATH.

**Solution:**
```bash
cd ../neoos-kernel
./toolchain/build.sh
export PATH=$(pwd)/toolchain/x86_64-elf/bin:$PATH

cd ../neoos-musl
make
```

## "upstream submodule not initialized"

**Cause:** git submodule update --init has not been run.

**Solution:**
```bash
cd neoos-musl
git submodule update --init upstream
make
```

## "configure: error: cannot run C compiled programs"

**This is expected!** The x86_64-elf target cannot run on the host machine.

If configure fails, check:
1. x86_64-elf-gcc is in PATH
2. Try running: `x86_64-elf-gcc --version`
3. Check upstream/config.log for details

## Build hangs or is very slow

musl configure can take 1-2 minutes to complete. Be patient.

If it hangs longer than 3 minutes:
1. Press Ctrl+C to stop
2. Check the log: `tail -50 upstream/config.log`
3. Look for error patterns
4. Try a clean build: `make clean && make`

## libc.a not found after build

Check if the build actually succeeded:
```bash
make verify
```

If verify fails:
1. Check build output for errors
2. Ensure PREFIX directory was created: `ls -la build-output/`
3. Try rebuilding: `make clean && make`

## Different errors?

Check the detailed build log:
```bash
# For configure errors:
tail upstream/config.log

# For make errors:
make 2>&1 | tail -20

# Full build with detailed output:
make clean
./build.sh 2>&1 | tee build.log
```
