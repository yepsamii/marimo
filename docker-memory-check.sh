#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🐳 Docker Memory Configuration Checker${NC}"
echo "========================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    exit 1
fi

# Get Docker memory info
DOCKER_INFO=$(docker system info --format "{{.MemTotal}}")
DOCKER_MEMORY_BYTES=$DOCKER_INFO
DOCKER_MEMORY_GB=$((DOCKER_MEMORY_BYTES / 1024 / 1024 / 1024))

echo -e "${GREEN}✅ Docker is running${NC}"
echo "📊 Available Docker Memory: ${DOCKER_MEMORY_GB} GB"

# Check minimum requirements
if [ $DOCKER_MEMORY_GB -lt 8 ]; then
    echo -e "${YELLOW}⚠️  WARNING: Docker has less than 8GB memory allocated${NC}"
    echo "   Your build may fail due to memory constraints"
    echo ""
    echo "🔧 To fix this:"
    echo "   1. Open Docker Desktop"
    echo "   2. Go to Settings → Resources → Memory"
    echo "   3. Increase to at least 8GB (12GB+ recommended)"
    echo "   4. Click 'Apply & restart'"
else
    echo -e "${GREEN}✅ Docker memory allocation looks good${NC}"
fi

echo ""
echo "📋 Build Commands:"
echo "   Standard build:    ./docker-build.sh"
echo "   Production build:  ./docker-build.sh --prod"
echo "   Docker Compose:    docker-compose up --build"
echo ""
echo "🚀 If build fails with memory errors:"
echo "   - Increase Docker Desktop memory allocation"
echo "   - Try: docker system prune -f (to free space)"
echo "   - Use: docker-compose up --build (includes memory limits)"