#!/bin/bash

# Build script for Docker with pre-built frontend assets
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🏗️  Building Puku Note with Pre-built Frontend${NC}"
echo "============================================="

# Check if frontend/dist exists
if [ ! -d "frontend/dist" ]; then
    echo -e "${RED}❌ frontend/dist not found!${NC}"
    echo "Please build the frontend first:"
    echo "  cd frontend"
    echo "  NODE_OPTIONS=\"--max-old-space-size=4096\" pnpm build"
    echo "  cd .."
    exit 1
fi

echo -e "${GREEN}✅ Found frontend/dist${NC}"

# Backup original .dockerignore
echo -e "${YELLOW}📝 Temporarily modifying .dockerignore${NC}"
cp .dockerignore .dockerignore.backup

# Use the simple dockerignore (that allows dist/)
cp .dockerignore.simple .dockerignore

# Build Docker image
echo -e "${GREEN}🐳 Building Docker image${NC}"
docker build -f Dockerfile.simple-build -t puku-note:latest .

# Restore original .dockerignore
echo -e "${YELLOW}📝 Restoring original .dockerignore${NC}"
mv .dockerignore.backup .dockerignore

echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo ""
echo "To run the container:"
echo "  docker run -p 2718:2718 -v \$(pwd)/notebooks:/app/notebooks puku-note:latest"
echo ""
echo "Or use docker-compose:"
echo "  docker-compose up"