# Multi-stage Dockerfile for Puku Note (marimo fork)
FROM node:20-slim AS frontend-builder

# Install pnpm
RUN npm install -g pnpm@9

# Set working directory
WORKDIR /app

# Copy package files (lockfile is in root, not frontend dir)
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json tsconfig.json biome.jsonc ./
COPY frontend/package.json ./frontend/
COPY packages/llm-info/package.json ./packages/llm-info/
COPY packages/lsp/package.json ./packages/lsp/
COPY packages/openapi/package.json ./packages/openapi/
COPY packages/ts-config/package.json ./packages/ts-config/
COPY patches/ ./patches/

# Install frontend dependencies
RUN rm -rf node_modules && pnpm install --no-frozen-lockfile

# Install tsx for codegen using npm (pnpm global requires setup)
RUN npm install -g tsx

# Copy source code
COPY frontend/ ./frontend/
COPY packages/ ./packages/

# Copy marimo Python schemas needed for codegen
COPY marimo/_schemas/ ./marimo/_schemas/

# Build frontend assets directly
ENV NODE_ENV=production
WORKDIR /app
# Run codegen first
RUN cd packages/llm-info && pnpm run codegen && \
    cd ../openapi && pnpm run codegen && \
    cd ../../frontend && pnpm run build

# Production stage
FROM python:3.11-slim AS runtime

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install uv for fast Python dependency management
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy Python package configuration and source code
COPY pyproject.toml README.md LICENSE ./
COPY marimo/ ./marimo/
COPY scripts/ ./scripts/

# Install Python dependencies
RUN uv pip install --system -e .

# Create _static directory and copy built frontend assets
RUN mkdir -p marimo/_static/
COPY --from=frontend-builder /app/frontend/dist/ ./marimo/_static/

# Create _lsp directory and copy LSP assets if they exist  
RUN mkdir -p marimo/_lsp/
COPY --from=frontend-builder /app/packages/lsp/dist/ ./marimo/_lsp/ 2>/dev/null || true

# Create directories for user data
RUN mkdir -p /app/notebooks /app/data

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Expose the default marimo port
EXPOSE 2718

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:2718/health')" || exit 1

# Default command - run marimo server
CMD ["python", "-m", "marimo", "edit", "--host", "0.0.0.0", "--port", "2718", "--no-token", "/app/notebooks"]

# Labels
LABEL org.opencontainers.image.title="Puku Note"
LABEL org.opencontainers.image.description="A reactive Python notebook that's reproducible, git-friendly, and deployable"
LABEL org.opencontainers.image.source="https://github.com/your-repo/puku-note"
LABEL org.opencontainers.image.licenses="Apache-2.0"