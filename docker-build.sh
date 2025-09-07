#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Default values
DOCKERFILE="Dockerfile"
TAG="puku-note:latest"
BUILD_ARGS=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --prod)
            DOCKERFILE="Dockerfile.prod"
            TAG="puku-note:prod"
            shift
            ;;
        --tag)
            TAG="$2"
            shift 2
            ;;
        --no-cache)
            BUILD_ARGS="--no-cache"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --prod       Use production Dockerfile (Dockerfile.prod)"
            echo "  --tag TAG    Set custom tag (default: puku-note:latest)"
            echo "  --no-cache   Build without using cache"
            echo "  --help, -h   Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Build development image"
            echo "  $0 --prod            # Build production image"
            echo "  $0 --tag my-tag      # Build with custom tag"
            echo "  $0 --prod --no-cache # Build production image without cache"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

print_status "Building Puku Note Docker image..."
print_status "Using Dockerfile: $DOCKERFILE"
print_status "Image tag: $TAG"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Build the Docker image
print_status "Starting Docker build..."
if docker build $BUILD_ARGS -f "$DOCKERFILE" -t "$TAG" .; then
    print_status "✅ Docker build completed successfully!"
    print_status "Image tagged as: $TAG"
    echo ""
    print_status "To run the container:"
    echo "  docker run -p 2718:2718 -v \$(pwd)/notebooks:/app/notebooks $TAG"
    echo ""
    print_status "Or use docker-compose:"
    echo "  docker-compose up"
else
    print_error "❌ Docker build failed!"
    exit 1
fi

# Show image information
print_status "Image information:"
docker images "$TAG" --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"