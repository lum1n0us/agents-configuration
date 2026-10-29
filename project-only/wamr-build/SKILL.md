---
name: wamr-build
description: Use when building WAMR components (wamrc, iwasm, libiwasm) - clean builds in devcontainer with fail-fast and logging
---

# WAMR Build

## Usage

```
wamr-build [targets...]     # targets: wamrc iwasm (default: both)
```

- `wamrc` → `wamr-compiler/`
- `iwasm` + `libiwasm` → `product-mini/platforms/linux/`

## Rules

1. **Devcontainer**: Run each command block below inside the devcontainer as one invocation: `devcontainer exec --workspace-folder=<repo root> -- bash -c "<block>"`. Logs live in the repo, which is bind-mounted, so `tee` runs inside the container too. Before each target, check with `devcontainer exec --workspace-folder=<repo root> -- echo "test"`. If the check fails, run `devcontainer up --workspace-folder=<repo root>` once and check again. If it still fails, STOP and report. Never fall back to the host.
2. **Clean**: Remove and recreate `build/` as a separate step before configure, so `tee` can open its file and no stale CMake cache is reused.
3. **Logging**: Logs go into the target's `build/` directory (`wamr-compiler/build/` or `product-mini/platforms/linux/build/`). Run every pipeline under `set -o pipefail`, so the exit code is the command's, not `tee`'s.
4. **Fail-fast**: On the first non-zero exit, STOP and report the log path.

## Build wamrc

```bash
set -o pipefail
cd wamr-compiler
rm -rf build && mkdir build
cmake -S . -B build [OPTIONS] 2>&1 | tee build/wamrc_configure.log
cmake --build build 2>&1 | tee build/wamrc_build.log
build/wamrc --version
```

## Build iwasm + libiwasm

```bash
set -o pipefail
cd product-mini/platforms/linux
rm -rf build && mkdir build
cmake -S . -B build [OPTIONS] 2>&1 | tee build/iwasm_configure.log
cmake --build build 2>&1 | tee build/iwasm_build.log
ls build/iwasm build/libiwasm.*
```

## Options

CMake options go after `cmake -S . -B build`, not after `cmake --build`:

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DWAMR_BUILD_GC=1
```
