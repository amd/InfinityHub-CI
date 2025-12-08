# AMD Fortran Compiler - User Guide


## Overview

This user guide provides instructions for obtaining the pre-production build of the AMD Fortran Compiler that has been released starting with AMD ROCm platform packages, version 7.0.
The document also contains information like usage, known issues, and system requirements.
The latest preview of the compiler is available through the following link:

[https://repo.radeon.com/rocm/misc/flang/](https://repo.radeon.com/rocm/misc/flang/)

The latest release is **drop 22.2.0**. You may obtain any of the supported OS through `wget`:

```shell
wget https://repo.radeon.com/rocm/misc/flang/rocm-afar-8873-drop-22.2.0-rhel.tar.bz2
wget https://repo.radeon.com/rocm/misc/flang/rocm-afar-8873-drop-22.2.0-sles.tar.bz2
wget https://repo.radeon.com/rocm/misc/flang/rocm-afar-8873-drop-22.2.0-ubu.tar.bz2
wget https://repo.radeon.com/rocm/misc/flang/rocm-afar-8873-drop-22.2.0-alma.tar.bz2
```
An AlmaLinux OS build is now available starting with drop 6.0.0:
- SLES 15 SP5 systems must use rocm-afar-####-drop-i.j.k-alma.tar.bz2
- SLES 15 SP6 systems can  use rocm-afar-####-drop-i.j.k-sles.tar.bz2


## System requirements

The AMD Fortran Compiler drops have similar requirements to the official ROCm releases.
They can be used on any of the following OS:

| CPUs | Operating Systems | ROCm™ Driver |
|----  |-----------------  |------------------ |
| X86_64 CPU(s) | [Ubuntu (version >= 22.04) <br> RHEL 8.x <br>  SLES 15 ](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html#supported-operating-systems) | [ROCm Latest](https://rocm.docs.amd.com/en/latest/) |

For ROCm installation procedures and validation checks, see:

* [ROCm Documentation](https://rocm.docs.amd.com)
* [ROCm Installation notes](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/).
* [ROCm Examples](https://github.com/amd/rocm-examples)


## Setting up the compiler

Download and untar the desired `rocm-afar-<latest version>-<OS>.tar.bz2` file anywhere onto your system:

```bash
tar jxf rocm-afar-<latest version>-<OS>.tar.bz2 -C <path to install>
```

It is then recommended to add `<path to install>/rocm-afar-<version>/bin` to your `PATH` and `<path to install>/rocm-afar-<version>/lib` to `LD_LIBRARY_PATH`.
Setting these allows the prebuilt compiler to work seamlessly with an existing ROCm installation on the system.


## Usage

- Compiler driver located in `bin/amdflang`.
- Compiler flags are generally `gfortran` compatible.  Use `--help` to see full list of supported flags.

AMD GPU related flags:

```bash
-fopenmp --offload-arch=<gfx>       Compile OpenMP target directives for a given GPU (e.g. gfx90a/MI250)
-fdo-concurrent-to-openmp=<value>   Try to map `do concurrent` loops to OpenMP [none|host|device]
-fopenmp-force-usm                  Force behavior as if the user specified pragma omp requires unified_shared_memory
 ```

Default data precision/conversion:

```bash
-fdefault-double-8                  Set the default double precision kind to an 8 byte wide type
-fdefault-integer-8                 Set the default integer and logical kind to an 8 byte wide type
-fdefault-real-8                    Set the default real kind to an 8 byte wide type
-fconvert=<value>                   Set endian conversion of data for unformatted files
                                        value: big-endian, little-endian, native
-ffast-math                         Enable less precise arithmetic optimizations
-ffast-real-mod                     Enable fast implementation of MOD for REAL types
 ```

Source form (determined by file extension by default):

```bash
-ffree-form                         Process source files in free form
-ffixed-form                        Process source files in fixed form
-ffixed-line-length=<value>         Use <value> as character line width in fixed mode
```

Alternate directory selection:

```bash
--gcc-toolchain=...                 Specify a directory where Clang can find 'include' and 'lib*'
--gcc-install-dir=...               Use GCC installation in the specified directory.
--rocm-path=...                     ROCm installation path.
-frtlib-add-rpath                   Add -rpath with architecture-specific resource directory to the linker flags.
-fno-rtlib-add-rpath                Don't add -rpath with architecture-specific resource directory to the linker flags.
-resource-dir=...                   Resource directory for use with -frtlib-add-rpath
 ```

Other:

```bash
--help                              See all supported options
```

## Using hipfort

>**NOTE:**  Starting with drop 6.0.0 hipfort is now included in the drop with modules built specifically for the AMD Fortran Compiler.

The following is only needed for older versions up to drop 5.3.0:
In order to use hipfort, it must be built from source using `amdflang` since the build provided with ROCm is not compatible with the AMD Fortran Compiler.
The following set of commands will build hipfort using `amdflang`.

```shell
git clone https://github.com/ROCm/hipfort.git
cd hipfort
mkdir build && cd build
cmake ../ -DHIPFORT_INSTALL_DIR=<install path> -DHIPFORT_BUILD_TYPE=RELEASE -DHIPFORT_COMPILER=$(which amdflang) \
          -DHIPFORT_COMPILER_FLAGS="-ffree-form -cpp" -DHIPFORT_AR=$(which ar) -DHIPFORT_RANLIB=$(which ranlib)
make -j install
```

>**NOTE:** In ROCm releases before version 7.0 and the AMD Optimizing CPU Compiler (AOCC) version 5.0, `amdflang` invokes the previous Fortran compiler based on the legacy Flang compiler.
With ROCm version 7.0 and preproduction drops, `amdflang` invokes the new AMD Fortran Compiler.

The hipfort library can be easily incorporated into GNU Make or CMake build systems.
A file `Makefile.hipfort` is provided in the install at `<install path>/share/hipfort/Makefile.hipfort` that is intended to be included by other Makefiles.
It sets a number of relevant variables for building and linking with hipfort.
See the comments in that file for usage instructions.
The following CMake targets are provided following `find_package(hipfort)`:

- `hipfort::hip`
- `hipfort::roctx`
- `hipfort::rocblas`
- `hipfort::hipblas`
- `hipfort::rocfft`
- `hipfort::hipfft`
- `hipfort::rocrand`
- `hipfort::hiprand`
- `hipfort::rocsolver`
- `hipfort::hipsolver`
- `hipfort::rocsparse`
- `hipfort::hipsparse`

These can be used to set the correct include paths and link lines via `target_include_directories` and `target_link_libraries`.
Use the library interface target corresponding to each [hipfort API](https://rocm.docs.amd.com/projects/hipfort/en/latest/doxygen/html/pages.html) that is required.


# AMD Flang OpenMP Feature Support Summary (Drop 22.2.0)

In addition to the features as of OpenMP API version 3.1 (supported by LLVM/Flang of the the LLVM project), the AMD Fortran Compiler has support for the following additional features from later OpenMP API versions.

| Category                      | Construct / Directive | Support Status         | Notes |
|-------------------------------|-----------------------|------------------------|-------|
| **Parallelism Constructs**    | `teams`               | ✅ Supported           | Multi-block teams, reductions, nesting checks |
|                               | `simd`                | ✅ Supported           | Combined forms, safelen/simdlen, linear/aligned |
| **Work-Sharing Constructs**   | `do` / `for`          | ✅ Fully Supported     | All schedules, collapse, ordered, canonical loops |
|                               | `workdistribute`      | ⚠️ In Development      | Claimed in 7.1.1, no details |
| **Tasking Constructs**        | `task`                | ✅ Fully Supported     | Full clause coverage, detach/event checks |
|                               | `taskloop`            | ⚠️ Likely Supported    | Infrastructure suggests support |
|                               | `taskyield`           | ✅ Supported           | Runtime support |
|                               | `taskgroup`           | ✅ Supported           | Task reductions, allocate clause |
|                               | `taskgraph`           | ⚠️ Parsing Only        | Parsing complete, lowering not detailed |
| **Device Constructs**         | `target`              | ✅ Fully Supported     | Full clause coverage, AMD GPU backend |
|                               | `target data`         | ✅ Supported           | Map/use_device_ptr/addr improvements |
|                               | `target enter/exit data` | ✅ Supported        | Full clause coverage |
|                               | `target update`       | ✅ Supported           | To/from, depend, nowait |
| **Loop Constructs**           | `loop`                | ✅ Fully Supported     | Standalone + combined forms, bind clause |
|                               | `distribute`          | ✅ Supported           | Dist_schedule, collapse, canonical loops |
| **Loop Transformations**      | `tile`                | ✅ Supported           | Standalone + nested loop tiling |
|                               | `unroll`              | ✅ Supported           | Full + partial unrolling |
| **Synchronization**           | `barrier`             | ✅ Supported           | Per-symbol checks |
|                               | `ordered`             | ✅ Supported           | Standalone with depend/doacross |
|                               | `taskwait`            | ✅ Supported           | Depend + nowait |
| **Cancellation**              | `cancel`              | ✅ Supported           | Parallel, sections, do/for, taskgroup |
|                               | `cancellation point`  | ✅ Supported           | Standard support |
| **Data Environment**          | `threadprivate`       | ✅ Supported           | Host association, default(none) fixes |
|                               | `declare reduction`   | ✅ Supported           | User-defined reductions, GPU combiner regions |
|                               | `declare mapper`      | ✅ Supported           | Custom mappers, derived types |
|                               | `scan`                | ⚠️ Backend Support     | IR builder changes, partial |
|                               | `groupprivate`        | ⚠️ Parsing Support     | Parsing + semantic checks only |
| **Variant Directives**        | `metadirective`       | ⚠️ Parsing/Semantics   | Context selectors, WHEN/OTHERWISE |
|                               | `declare variant`     | ⚠️ Parsing Supported   | Context match parsing |
|                               | `declare simd`        | ⚠️ Parsing Supported   | Scoping checks |
|                               | `declare target`      | ✅ Supported           | Device_type, link, indirect clauses |
|                               | `dispatch`            | ⚠️ Parsing Support     | Parsing only |
| **Utility Directives**        | `requires`            | ✅ Supported           | Unified memory, atomic default mem order |
|                               | `assumes`             | ✅ Supported           | Assumption parsing |


## Known issues

- ICE when variables with the CONTIGUOUS attribute are used in kernels.
- OpenMP atomic on complex operations currently not supported (work in progress)
- `REAL kind=2,3,10,16` types are not yet supported (work in progress)
- When compiling for offload, add `-lFortranRuntimeHostDevice` (up to  drop 5.3.0) or `-lflang_rt.hostdevice` (starting from drop 6.0.0) if you see unresolved symbols such as:
```bash
error: undefined symbol: _FortranAAssign
```

Note that this is not added to the link line by default as calling too much of the runtime from device can result in lower performance.
Seeing these undefined symbols gives the user an indication that the target region is calling something in the Fortran runtime which could
result in performance issues. Adding the FortranRuntimeHostDevice library will allow the program to link and run without further
modification to the user's program.

**NOTE:** Library changes starting from drop 6.0.0 (if linking explicitly to any of these)
- The host runtime libraries in 5.3.0:
    -  llvm/lib/libFortranRuntime.a has been replaced with llvm/lib/libflang_rt.runtim
    -  llvm/lib/libFortranDecimal.a has been replaced with llvm/lib/libflang_rt.quadmath.a (only needed if app uses 128-bit FP)
- The device runtime library in 5.3.0:
    - llvm/lib/libFortranRuntimeHostDevice.a has been replaced with llvm/lib/libflang_rt.hostdevice.a


## Reporting issues

Bugs and other issues can be reported to [AMD's fork of the LLVM project](https://github.com/ROCm/llvm-project/issues).
When reporting an issue please create a minimal reproducer and clearly describe the cause.
A good reproducer often has the following characteristics:

1. Dependencies on external libraries are removed
2. Code exists in a single or small number of files

All bug reports should also include:

1. The version of the compiler where the issue can be reproduced
2. The complete output of any error (an additional abbreviated message may be added for clarity)
3. Directions capturing all compiler and executable invocations that reproduce the issue


## Disclaimer

PRE-PRODUCTION SOFTWARE:  The software accessible on this page may be a pre-production version, intended to provide advance access to features
that may or may not eventually be included into production version of the software.  Accordingly, pre-production software may not be fully
functional, may contain errors, and may have reduced or different security, privacy, accessibility, availability, and reliability standards
relative to production versions of the software. Use of pre-production software may result in unexpected results, loss of data, project delays
or other unpredictable damage or loss.  Pre-production software is not intended for use in production, and your use of pre-production software
is at your own risk.


## Notices and Attribution

© 2022-2025 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
