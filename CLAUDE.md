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
make typos            # Check for typos

# API and code generation
make fe-codegen       # Generate frontend API from OpenAPI spec
make py-snapshots     # Update Python test snapshots

# Documentation
make docs             # Build documentation
make docs-serve       # Serve documentation locally

# Packaging
make wheel            # Build Python wheel
```

### Running specific tests
```bash
# Python tests with hatch
hatch run +py=3.12 test:test tests/path/to/test.py
hatch run +py=3.12 test-optional:test tests/path/to/test.py  # With optional deps

# Frontend tests with pnpm
cd frontend && pnpm test src/path/to/file.test.ts

# End-to-end tests
cd frontend && pnpm playwright test
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
  
- **Server** (`_server/`): Starlette-based ASGI web server
  - WebSocket communication for real-time updates
  - Session management for multiple notebooks
  - API endpoints in `_server/api/`
  - Template rendering in `_server/templates/`
  
- **Plugins** (`_plugins/`): Extensible UI components
  - Interactive elements (sliders, buttons)
  - Display components (charts, markdown)

### 2. TypeScript Frontend (`/frontend/src/`)
- **Core** (`core/`): Application state and kernel communication
  - Cell state management (`cells/`)
  - WebSocket connection handling (`websocket/`)
  - Configuration management (`config/`)
  - Network layer (`network/`)
  
- **Components** (`components/`): UI elements
  - Editor and cell UI (`editor/`)
  - Data tables and visualizations
  - Chrome/sidebar panels (`editor/chrome/`)
  
- **Plugin System** (`plugins/`): Renders Python-generated UI

### 3. Communication Layer
- **WebSocket Protocol**: Bidirectional messaging between frontend and backend
  - Operations: kernel → frontend (outputs, errors)
  - Requests: frontend → kernel (run cell, UI updates)
  - Message protocols defined in `marimo/_messaging/ops.py`
  
- **Reactive Execution**: When a cell changes, marimo automatically:
  1. Analyzes dependencies via AST processing
  2. Queues downstream cells based on dependency graph
  3. Re-executes cells in dependency order

## Key Concepts

- **Reactive Dataflow**: Cells automatically re-run when their dependencies change
- **No Hidden State**: Deleting a cell removes its variables from memory
- **Pure Python Files**: Notebooks stored as `.py` files, not JSON
- **UI Binding**: Interactive elements automatically trigger cell re-execution
- **Session Management**: Multiple notebook sessions with isolated state

## Code Style Guidelines

### Python
- Follow PEP 8 style guide with type hints consistently
- Use marimo's logger: `from marimo import _loggers; LOGGER = _loggers.marimo_logger()`
- Write pytest tests for new functionality in `tests/` folder
- Use snapshot testing where appropriate with `from tests.mocks import snapshotter`
- Handle errors with try-except blocks and appropriate logging levels
- Don't log sensitive information (tokens, passwords)
- Use descriptive variable names and minimal comments

### Frontend (React/TypeScript)
- Use functional components, avoid classes
- TypeScript with proper typing for all new code
- Use Tailwind CSS for styling
- UI components in `@/components/ui` (customized from Radix)
- Test with Vitest, covering all edge cases
- Use React Hook Form with Zod for forms
- Prefer composition over inheritance
- Use descriptive variable names with auxiliary verbs (isLoading, hasError)
- Named exports preferred over default exports

## Important Files

**Backend Entry Points:**
- `marimo/__init__.py` - Public API
- `marimo/_runtime/runtime.py` - Kernel core
- `marimo/_server/main.py` - Web server entry point
- `marimo/_server/asgi.py` - ASGI application

**Frontend Entry Points:**
- `frontend/src/main.tsx` - App bootstrap
- `frontend/src/core/MarimoApp.tsx` - Root component
- `frontend/src/core/websocket/useMarimoWebSocket.tsx` - WebSocket communication
- `frontend/src/mount.tsx` - Application mounting logic

**Core Systems:**
- `marimo/_runtime/dataflow.py` - Reactivity engine
- `marimo/_ast/cell.py` - Cell abstraction
- `marimo/_messaging/ops.py` - Message protocols
- `marimo/_server/sessions.py` - Session management
- `frontend/src/core/cells/cells.ts` - Frontend cell state

**Build System:**
- `scripts/buildfrontend.sh` - Frontend build script
- `scripts/buildlsp.sh` - LSP build script
- `frontend/vite.config.mts` - Vite configuration
- `pyproject.toml` - Python packaging and dependencies

## Template and Title System

marimo uses server-side template rendering for HTML pages:
- `marimo/_server/templates/templates.py` - Template processing functions
- `marimo/_server/api/utils.py` - Title parsing utilities
- Templates replace placeholders like `{{ title }}`, `{{ version }}`, `{{ mount_config }}`
- Titles can be customized in both home page and notebook page templates

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.