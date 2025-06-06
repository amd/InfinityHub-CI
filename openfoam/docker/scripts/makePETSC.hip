#!/bin/sh
#------------------------------------------------------------------------------
# =========                 |
# \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
#  \\    /   O peration     |
#   \\  /    A nd           | www.openfoam.com
#    \\/     M anipulation  |
#------------------------------------------------------------------------------
#     Copyright (C) 2018-2021 OpenCFD Ltd.
#------------------------------------------------------------------------------
# License
#     This file is part of OpenFOAM, distributed under GPL-3.0-or-later.
#
# Script
#     makePETSC.hip
#
# Description
#     Build script for PETSC with HIP support
#
# ----------------------------------------------
# NO USER-CONFIGURABLE SETTINGS WITHIN THIS FILE
#------------------------------------------------------------------------------
if :    # Run from third-party directory
then
    cd "${0%/*}" || exit
    wmakeCheckPwd "$WM_THIRD_PARTY_DIR" 2>/dev/null || {
        echo "Error (${0##*/}) : not located in \$WM_THIRD_PARTY_DIR"
        echo "    Check your OpenFOAM environment and installation"
        exit 1
    }
fi
. "${WM_THIRD_PARTY_DIR:?}"/etc/tools/ThirdPartyFunctions
#------------------------------------------------------------------------------
_foamConfig petsc

PETSC_PACKAGE="${petsc_version:-none}"
targetType=libso

unset HYPRE_PACKAGE
unset HYPRE_ARCH_PATH   # Avoid inconsistency

if nonStandardPlatforms  # Possibly unreliable inherited values
then
    unset PETSC_ARCH_PATH
fi

#------------------------------------------------------------------------------
printVersions() { listPackageVersions petsc; exit 0; }
printHelp() {
    cat<<USAGE

Usage: ${0##*/} [OPTION] [lib|libso] [HYPRE-VERSION] [PETSC-VERSION] [-- configure-options]
options:
  -force        Force compilation, even if include/library already exists
  -gcc          Force use of gcc/g++
  -inplace      Build/install inplace (expert option)
  -debug        Build with debugging enabled
  -hypre=URL    Specify hypre download location
  -no-hypre     Disable automatic hypre download/detection
  -list         List available unpacked source versions
  -help         Display usage help

* build PETSC with
      ${PACKAGE:-[unspecified]}

USAGE
    showDownloadHint petsc

    echo
    echo "Many people who have downloaded PETSC have also downloaded HYPRE :"
    showDownloadHint hypre

    exit 0  # Clean exit
}
#------------------------------------------------------------------------------
exportCompiler          # Compiler info for CMake/configure

unset optDebug optForce optInplace optHypre

# Parse options
while [ "$#" -gt 0 ]
do
    case "$1" in
    '') ;;      # Ignore empty
    --) break;; # Extra configure options (leave on $@ for later detection)
    -h | -help*) printHelp;;
    -list)      printVersions;;
    -gcc)       useGcc  ;;
    -force)     optForce=true ;;
    -inplace)   optInplace=true ;;
    -debug)     optDebug=true ;;

    lib|libso)  targetType="$1" ;;

    -hypre=*)
        optHypre="${1#*=}"      # URL for download
        unset HYPRE_PACKAGE HYPRE_ARCH_PATH
        ;;

    -no-hypre)
        optHypre=false
        unset HYPRE_PACKAGE HYPRE_ARCH_PATH
        ;;

    hypre-[0-9]* | hypre-git)
        HYPRE_PACKAGE="${1%%/}"
        unset optHypre
        unset HYPRE_ARCH_PATH   # Avoid inconsistency
        ;;

    petsc/* | sources/petsc* |\
    petsc-[0-9]* | petsc-git)
        PETSC_PACKAGE="${1%%/}"
        unset PETSC_ARCH_PATH   # Avoid inconsistency
        ;;
    *)
        die "unknown option/argument: '$1'"
        ;;
    esac
    shift
done

if [ -z "$PETSC_PACKAGE" ]
then
    die "The PETSC package/version not specified"
elif _foamIsNone "$PETSC_PACKAGE" || _foamIsSystem "$PETSC_PACKAGE"
then
    echo "Using none/system (skip ThirdParty build of PETSC)"
    exit 0
fi

#------------------------------------------------------------------------------
# Integrations

# Clunky
if [ -z "$optHypre" ] && [ -n "$HYPRE_PACKAGE" ] \
&& ! _foamIsNone "$HYPRE_PACKAGE"
then
    echo "Using $HYPRE_PACKAGE"
    : "${HYPRE_ARCH_PATH:=$installBASE$WM_SIZE_OPTIONS/$HYPRE_PACKAGE}"
fi


#------------------------------------------------------------------------------
#
# Build PETSC
#
#   PETSC_ARCH_PATH : installation directory (as per config file)
#
#   *PACKAGE : name-version of the package
#   *SOURCE  : location of original sources
#   *PREFIX  : installation directory

PETSC_SOURCE="$(findSourceDir "$PETSC_PACKAGE")"
PETSC_PACKAGE="$(basename "$PETSC_PACKAGE")"
PETSC_PREFIX="$installBASE$WM_SIZE_OPTIONS/$PETSC_PACKAGE"

# Override as per config file (if any)
[ -n "$PETSC_ARCH_PATH" ] && PETSC_PREFIX="$PETSC_ARCH_PATH"

[ -d "$PETSC_SOURCE" ] || {
    echo "Missing sources: '$PETSC_PACKAGE'"
    showDownloadHint petsc
    exit 2
}


# PETSC arch - same root as WM_OPTIONS (eg, DPInt32)
archOpt="$WM_SIZE_OPTIONS"

if [ -n "$optInplace" ]
then
    # Inplace installation. No install stage required
    unset PETSC_PREFIX
    makeInstall() { true; }
else
    # Regular installation location (PETSC_PREFIX)

    makeInstall() {
        make PETSC_DIR="$PETSC_SOURCE" PETSC_ARCH="$archOpt" install
        pkgconfigAdjust "$PETSC_PREFIX"
    }
fi

echo "Starting build: $PETSC_PACKAGE ($targetType)"
if [ "$WM_PRECISION_OPTION" = SP ]
then
    optHypre=false  # No single-precision hypre
    echo "No single-precision hypre"
fi
if [ -d "$PETSC_SOURCE/$archOpt/externalpackages" ]
then
    echo "Removing old $archOpt/externalpackages"
    rm -rf "$PETSC_SOURCE/$archOpt/externalpackages"
fi
echo
(
    # Configuration options

    # Compiler or MPI (but not both)
    # if [ -d "$MPI_ARCH_PATH" ]
    # then
    #     configOpt="--with-mpi-dir=$MPI_ARCH_PATH"
    # else
        configOpt="--with-cc=$(whichMpicc) --with-cxx=$(whichMpicxx)"
    # fi

    if [ "$optDebug" = true ]
    then
        configOpt="$configOpt --with-debugging=1"
    else
        # A reasonable assumption for optimization
        configOpt="$configOpt --with-debugging=0"
        configOpt="$configOpt --COPTFLAGS=-O3 --CXXOPTFLAGS=-O3"
    fi

    if [ "$targetType" = libso ]
    then
        configOpt="$configOpt --with-shared-libraries"
    fi

    if [ "$WM_LABEL_SIZE" = 64 ]
    then
        configOpt="$configOpt --with-64-bit-indices=1"
    else
        configOpt="$configOpt --with-64-bit-indices=0"
    fi

    if [ "$WM_PRECISION_OPTION" = SP ]
    then
        configOpt="$configOpt --with-precision=single"
    else
        configOpt="$configOpt --with-precision=double"
    fi

    case "$optHypre" in
    false)
        configOpt="$configOpt --with-hypre=0"
        ;;
    ftp:* | git:* | http:* | https:*)
        configOpt="$configOpt --download-hypre=$optHypre"
        ;;
    *)
        # This is a really clunky way to use ThirdParty hypre
        if [ -f "$HYPRE_ARCH_PATH/include/HYPRE.h" ]
        then
            echo "Has installed hypre: $HYPRE_PACKAGE"
            configOpt="$configOpt --with-hypre-dir=$HYPRE_ARCH_PATH"
        else
            configOpt="$configOpt --download-hypre"
        fi
    ;;
    esac

    # Additional configure options
    if [ "$1" = "--" ]
    then
        shift
        configOpt="$configOpt $@"
    fi

    # We export compiler settings (above) but actually use the
    # --with-cc and --with-cxx. So ignore these environment variables.

    unset CC CXX
    unset CFLAGS CXXFLAGS

    cd "$PETSC_SOURCE" || exit
    unset GIT_DIR # No special git-repo handling

    if [ -n "$PETSC_PREFIX" ]
    then
        rm -rf "$PETSC_PREFIX"
    fi
    # No clean here, if we have multiple arch in the same directory

    echo
    set -x
    ./configure \
        ${PETSC_PREFIX:+--prefix="$PETSC_PREFIX"} \
       --PETSC_DIR="$PETSC_SOURCE" \
       --with-petsc-arch="$archOpt" \
       --with-cc=mpicc --with-cxx=mpicxx --with-fc=mpifort --with-mpiexec=mpirun \
       FOPTFLAGS="-g -O3" \
       HIPOPTFLAGS="-g -O3 -fPIC -fdenormal-fp-math=ieee -munsafe-fp-atomics -w" \
       --with-cuda=0 \
       --with-hip=1 --with-hipc=hipcc --with-hip-dir=${ROCM_PATH} \
       --with-hip-arch=$AMDGPU_TARGETS \
       --with-clanguage=c \
       --download-fblaslapack \
       $configOpt \
     && set +x \
     && echo "Configured: petsc" \
     && make ${WM_NCOMPPROCS:+-j $WM_NCOMPPROCS} \
            PETSC_DIR="$PETSC_SOURCE" PETSC_ARCH="$archOpt" all \
     && echo "Built: petsc" \
     && makeInstall \
     && echo "Installed: $PETSC_PACKAGE"
) || {
    echo "Error building: $PETSC_PACKAGE"
    exit 1
}


#------------------------------------------------------------------------------
