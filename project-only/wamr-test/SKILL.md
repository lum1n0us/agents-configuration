---
name: wamr-test
description: Use when testing WAMR changes - runs comprehensive test suites (spec with 6 variants, regression, unit, sample) in devcontainer with fail-fast
---

# WAMR Test

## Usage

```
wamr-test [suites...] [--all-spec-variants] [--unit-modes <list>]     # suites: spec unit sample regression
```

## Rules

1. **Scope**:
   - User names suites → run exactly those.
   - Otherwise run **spec** (basic variant only) and **unit**, plus the suites matched by the modification (`git diff --name-only main` plus `git ls-files --others --exclude-standard`):
     - `tests/regression/` changed → regression
     - `samples/` changed → sample
   - All six spec variants run only when the caller explicitly passes `--all-spec-variants`.
   - Unit test modes default to `classic-interp` and `aot`. `--unit-modes` takes a comma-separated list from `classic-interp`, `fast-interp`, `jit`, `aot`, and replaces the `for` list in the unit-test block. `fast-jit` and `multi-tier-jit` have no unit test cases and are not accepted.
   - Never drop a default suite based on the change's size or risk.
2. **Order**: Sequential only: spec → unit → sample → regression.
3. **Devcontainer**: Run each command block in the Suites section inside the devcontainer as one invocation: `devcontainer exec --workspace-folder=<repo root> -- bash -c "<block>"`. Logs live in the repo, which is bind-mounted, so `tee` runs inside the container too. Before each suite, check with `devcontainer exec --workspace-folder=<repo root> -- echo "test"`. If the check fails, run `devcontainer up --workspace-folder=<repo root>` once and check again. If it still fails, STOP and report. Never fall back to the host.
4. **Fail-fast**: On the first non-zero exit, STOP and report `❌ [suite] failed` with the log path. Do not run the remaining commands, even if asked. For a "flaky" claim, read the log and ask for evidence; do not skip the test.
5. **Logging**: Each suite writes its logs into the output directory its own test process uses. Create the directory before the pipeline starts, since `tee` opens its file at start. Run every pipeline under `set -o pipefail`, so the exit code is the command's, not `tee`'s.

   | Suite | Log directory |
   |-------|---------------|
   | spec | `tests/wamr-test-suites/workspace/report/` |
   | unit | `tests/unit/build/` |
   | sample | `samples/<name>/build/` |
   | regression | `tests/regression/ba-issues/build/` |

## Suites

### spec-test

Default (basic variant only):

```bash
set -o pipefail
mkdir -p tests/wamr-test-suites/workspace/report
cd tests/wamr-test-suites/
./test_wamr.sh -s spec -b 2>&1 | tee workspace/report/spec_basic.log
```

All six variants, only with `--all-spec-variants`:

```bash
set -o pipefail
mkdir -p tests/wamr-test-suites/workspace/report
cd tests/wamr-test-suites/
./test_wamr.sh -s spec -b         2>&1 | tee workspace/report/spec_basic.log
./test_wamr.sh -s spec -b -M      2>&1 | tee workspace/report/spec_multi_module.log
./test_wamr.sh -s spec -b -G      2>&1 | tee workspace/report/spec_gc.log
./test_wamr.sh -s spec -b -W      2>&1 | tee workspace/report/spec_memory64.log
./test_wamr.sh -s spec -b -E      2>&1 | tee workspace/report/spec_multi_memory.log
./test_wamr.sh -s spec -b -N      2>&1 | tee workspace/report/spec_extended_const.log
```

### unit-test

Default modes: `classic-interp aot`. Each mode builds into `build/<mode>/`; logs are `build/unit_<mode>_*.log`.

```bash
set -o pipefail
cd tests/unit/
rm -rf build && mkdir build
for mode in classic-interp aot; do
  case ${mode} in
    classic-interp) flags="-DWAMR_BUILD_INTERP=1 -DWAMR_BUILD_FAST_INTERP=0 -DWAMR_BUILD_JIT=0 -DWAMR_BUILD_AOT=0" ;;
    fast-interp)    flags="-DWAMR_BUILD_INTERP=1 -DWAMR_BUILD_FAST_INTERP=1 -DWAMR_BUILD_JIT=0 -DWAMR_BUILD_AOT=0" ;;
    jit)            flags="-DWAMR_BUILD_INTERP=0 -DWAMR_BUILD_FAST_INTERP=0 -DWAMR_BUILD_JIT=1 -DWAMR_BUILD_AOT=0 -DWAMR_BUILD_FAST_JIT=0" ;;
    aot)            flags="-DWAMR_BUILD_INTERP=0 -DWAMR_BUILD_FAST_INTERP=0 -DWAMR_BUILD_JIT=0 -DWAMR_BUILD_AOT=1" ;;
  esac
  cmake -S . -B build/${mode} -DWAMR_BUILD_TARGET=X86_64 ${flags} 2>&1 | tee build/unit_${mode}_cmake.log || exit 1
  cmake --build build/${mode}                        2>&1 | tee -a build/unit_${mode}_cmake.log || exit 1
  ctest --test-dir build/${mode} --output-on-failure 2>&1 | tee build/unit_${mode}_ctest.log || exit 1
done
```

### sample-test

All samples with a `CMakeLists.txt`, except `minimum` (preset-only, no tests registered), in alphabetical order:

```bash
set -o pipefail
for dir in samples/*/; do
  name=$(basename "$dir")
  [ -f "$dir/CMakeLists.txt" ] || continue
  [ "$name" = minimum ] && continue
  rm -rf "$dir/build" && mkdir "$dir/build" || exit 1
  (cd "$dir" && cmake -S . -B build \
    && cmake --build build --config Debug --parallel 4 \
    && ctest --test-dir build --output-on-failure) 2>&1 | tee "$dir/build/sample.log" || exit 1
done
```

### regression-test

`build_run.py` without `--mode` runs every active running mode.

```bash
set -o pipefail
cd tests/regression/ba-issues/
mkdir -p build
python3 build_run.py 2>&1 | tee build/regression.log
```
