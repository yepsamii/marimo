# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Prerequisites and Setup
```bash
# Install prerequisites (required tools):
# - pnpm v9+ (package manager)
# - Node.js v20+
# - Python 3.9+ (for development)
# Optional but recommended:
# - uv (Python dependency manager)  
# - hatch (environment management)

# First-time setup (with prerequisites installed):
make check-prereqs     # Verify all tools are installed
make install-all       # Install all dependencies (frontend & Python)

# Alternative setup (without uv/hatch):
make fe                # Build frontend only
python3 -m venv venv   # Create virtual environment
source venv/bin/activate  # Activate virtual environment
pip install -e ".[dev]"   # Install Python dependencies
```

### Common Development Tasks
```bash
# Build and run
make fe               # Build frontend assets
make py               # Install Python dependencies in editable mode
make dev              # Start development servers with hot reloading

# Testing
make test             # Run all tests (frontend, Python, end-to-end)
make py-test          # Run Python tests only
make fe-test          # Run frontend tests only  
make e2e              # Run end-to-end tests

# Linting and formatting
make check            # Run all checks (lint, typecheck, format)
make py-check         # Python: typecheck, lint, format
make fe-check         # Frontend: lint and typecheck

# Documentation
make docs             # Build documentation
make docs-serve       # Serve documentation locally
```

### Running specific tests
```bash
# Python tests with hatch
hatch run +py=3.12 test:test tests/path/to/test.py
hatch run +py=3.12 test-optional:test tests/path/to/test.py  # With optional deps

# Frontend tests with pnpm
cd frontend && pnpm test src/path/to/file.test.ts
```

## High-Level Architecture

marimo is a reactive Python notebook system with three main components:

### 1. Python Backend (`/marimo/`)
- **Runtime System** (`_runtime/`): Core execution engine with reactive dataflow
  - `runtime.py`: Main kernel execution
  - `dataflow.py`: Dependency graph management  
  - Cell execution follows a directed graph where edges represent variable dependencies
  
- **AST Processing** (`_ast/`): Code analysis and compilation
  - Parses Python to extract variable definitions/references
  - Builds reactive dependency graph
  
- **Server** (`_server/`): Starlette-based web server
  - WebSocket communication for real-time updates
  - Session management for multiple notebooks
  
- **Plugins** (`_plugins/`): Extensible UI components
  - Interactive elements (sliders, buttons)
  - Display components (charts, markdown)

### 2. TypeScript Frontend (`/frontend/src/`)
- **Core** (`core/`): Application state and kernel communication
  - Cell state management
  - WebSocket connection handling
  
- **Components** (`components/`): UI elements
  - Editor and cell UI
  - Data tables and visualizations
  
- **Plugin System** (`plugins/`): Renders Python-generated UI

### 3. Communication Layer
- **WebSocket Protocol**: Bidirectional messaging
  - Operations: kernel → frontend (outputs, errors)
  - Requests: frontend → kernel (run cell, UI updates)
  
- **Reactive Execution**: When a cell changes, marimo automatically:
  1. Analyzes dependencies
  2. Queues downstream cells
  3. Re-executes in dependency order

## Key Concepts

- **Reactive Dataflow**: Cells automatically re-run when their dependencies change
- **No Hidden State**: Deleting a cell removes its variables from memory
- **Pure Python Files**: Notebooks stored as `.py` files, not JSON
- **UI Binding**: Interactive elements automatically trigger cell re-execution

## Code Style Guidelines

### Python
- Follow PEP 8 style guide
- Use type hints consistently
- Use marimo's logger: `from marimo import _loggers`
- Write pytest tests for new functionality in `tests/` folder
- Use snapshot testing where appropriate

### Frontend (React/TypeScript)
- Use functional components, avoid classes
- TypeScript with proper typing for all new code
- Use Tailwind CSS for styling
- UI components in `@/components/ui`
- Test with Vitest for edge cases

## Important Files

**Backend Entry Points:**
- `marimo/__init__.py` - Public API
- `marimo/_runtime/runtime.py` - Kernel core
- `marimo/_server/main.py` - Web server

**Frontend Entry Points:**
- `frontend/src/main.tsx` - App bootstrap
- `frontend/src/core/MarimoApp.tsx` - Root component
- `frontend/src/core/websocket/useMarimoWebSocket.tsx` - Communication

**Core Systems:**
- `marimo/_runtime/dataflow.py` - Reactivity engine
- `marimo/_ast/cell.py` - Cell abstraction
- `marimo/_messaging/ops.py` - Message protocols

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.