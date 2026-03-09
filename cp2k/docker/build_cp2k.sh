#!/bin/bash
#
# CP2K Docker Build Script
# This script builds the CP2K Docker image with caching and image reuse support
#
# Usage:
#   ./build_cp2k.sh [--clean] [--no-cache] [--cache-from IMAGE] [--dockerfile FILE]
#
# Options:
#   --clean        Clean up old containers and images before building
#   --no-cache     Build without using Docker cache
#   --cache-from   Use specified image as cache source
#   --dockerfile   Use specified Dockerfile (default: Dockerfile)
#

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure we're in the cp2k/docker directory
cd "$SCRIPT_DIR"

# Verify we're in the right directory (cp2k/docker)
if [ ! -f "Dockerfile" ] || [ ! -f "spack.sh" ] || [ ! -d "cp2k_environment" ]; then
    echo "Error: Required files not found. Please run this script from the cp2k/docker directory."
    echo "Current directory: $(pwd)"
    echo "Expected files: Dockerfile, spack.sh, cp2k_environment/"
    exit 1
fi

# Configuration
IMAGE_NAME="cp2k"
IMAGE_TAG="latest"
BASE_IMAGE="rocm/dev-ubuntu-24.04:7.0-complete"
CACHE_DIR="${SCRIPT_DIR}/cache"
SPACK_CACHE_DIR="${CACHE_DIR}/spack"
BUILD_LOG="${SCRIPT_DIR}/build.log"
DOCKERFILE="${SCRIPT_DIR}/Dockerfile"

# Parse arguments
CLEAN=false
NO_CACHE=false
CACHE_FROM=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN=true
            shift
            ;;
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        --cache-from)
            CACHE_FROM="$2"
            shift 2
            ;;
        --dockerfile)
            DOCKERFILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--clean] [--no-cache] [--cache-from IMAGE] [--dockerfile FILE]"
            echo ""
            echo "Options:"
            echo "  --clean          Clean up old containers/images"
            echo "  --no-cache       Build without Docker cache"
            echo "  --cache-from     Use specified image as cache source"
            echo "  --dockerfile     Use specified Dockerfile (default: Dockerfile)"
            exit 1
            ;;
    esac
done

# Cleanup function
cleanup() {
    echo "=== Cleaning up old containers and images ==="
    
    # Stop and remove containers
    docker ps -a --filter "ancestor=${IMAGE_NAME}:${IMAGE_TAG}" --format "{{.ID}}" | xargs -r docker rm -f 2>/dev/null || true
    
    # Remove old images (keep the latest)
    OLD_IMAGES=$(docker images "${IMAGE_NAME}" --format "{{.ID}}" | tail -n +2)
    if [ -n "$OLD_IMAGES" ]; then
        echo "$OLD_IMAGES" | xargs -r docker rmi -f 2>/dev/null || true
    fi
    
    echo "Cleanup complete"
}

# Create cache directories
setup_cache() {
    echo "=== Setting up cache directories ==="
    mkdir -p "${SPACK_CACHE_DIR}"
    mkdir -p "${CACHE_DIR}/build"
    echo "Cache directory: ${CACHE_DIR}"
    echo "Spack cache: ${SPACK_CACHE_DIR}"
}

# Build function
build_image() {
    # Ensure we're still in the correct directory
    cd "$SCRIPT_DIR"
    
    echo "=== Building Docker image ==="
    echo "Working directory: $(pwd)"
    echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
    echo "Dockerfile: $(basename "$DOCKERFILE")"
    echo "Base image: ${BASE_IMAGE}"
    echo "Build log: ${BUILD_LOG}"
    echo ""
    
    # Prepare build arguments
    BUILD_ARGS=(
        --tag "${IMAGE_NAME}:${IMAGE_TAG}"
        --file "$(basename "$DOCKERFILE")"
        --build-arg "IMAGE=${BASE_IMAGE}"
    )
    
    
    # Add cache-from if specified
    if [ -n "$CACHE_FROM" ]; then
        echo "Using cache from: ${CACHE_FROM}"
        BUILD_ARGS+=(--cache-from "${CACHE_FROM}")
    fi
    
    # Add no-cache if requested
    if [ "$NO_CACHE" = true ]; then
        echo "Building without cache"
        BUILD_ARGS+=(--no-cache)
    fi
    
    # Use BuildKit for advanced caching features
    export DOCKER_BUILDKIT=1
    
    # Build the image from the current directory (cp2k/docker)
    echo "Starting build at $(date)"
    echo "Build context: $(pwd)"
    if docker build "${BUILD_ARGS[@]}" . 2>&1 | tee "${BUILD_LOG}"; then
        echo ""
        echo "=== Build completed successfully at $(date) ==="
        docker images "${IMAGE_NAME}:${IMAGE_TAG}"
        return 0
    else
        echo ""
        echo "=== Build failed ==="
        echo "Check ${BUILD_LOG} for details"
        return 1
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "CP2K Docker Build Script"
    echo "=========================================="
    echo ""
    
    if [ "$CLEAN" = true ]; then
        cleanup
        echo ""
    fi
    
    setup_cache
    echo ""
    
    build_image
}

# Run main function
main "$@"
