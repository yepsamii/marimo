# Frontend Development & Visual Testing Guide

This guide covers setting up and testing the marimo frontend for development.

## Prerequisites

- **Node.js v20+** (check with `node --version`)
- **pnpm v9+** (check with `pnpm --version`)
- **Python 3.9+** (for running the backend server)

## Quick Start

### 1. Install Dependencies

```bash
# From the project root
cd /Users/yepsamii/Desktop/Projects/marimo

# Install frontend dependencies
pnpm install

# Build frontend assets
make fe
```

### 2. Set Up Python Backend

```bash
# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install -e ".[dev]"
```

## Development Modes

### Option 1: Hot Reload Development (Recommended for UI work)

This mode provides instant feedback when making frontend changes:

```bash
# Terminal 1: Start the backend server (headless mode)
source venv/bin/activate
marimo edit --headless --no-token

# Terminal 2: Start the frontend dev server with hot reload
cd frontend
pnpm dev
```

Now open http://localhost:5173 in your browser. Changes to frontend code will automatically reload.

### Option 2: Production-like Development

This mode builds the frontend and serves it through the Python server:

```bash
# Build frontend in watch mode (Terminal 1)
cd frontend
pnpm build:watch

# Run marimo server (Terminal 2)
source venv/bin/activate
marimo edit --no-token
```

Open http://localhost:2718 in your browser.

### Option 3: Quick Development

For quick testing without hot reload:

```bash
# Build frontend and start server
make fe && marimo edit --no-token
```

## Visual Testing Tools

### 1. Storybook (Component Library)

View and test individual UI components in isolation:

```bash
cd frontend
pnpm storybook
```

Opens at http://localhost:6006

### 2. End-to-End Tests (Visual)

Run Playwright tests with UI mode for visual debugging:

```bash
# Run all e2e tests with UI
cd frontend
pnpm playwright test --ui

# Run specific test file
pnpm playwright test cells.spec.ts --ui

# Debug mode (step through tests)
pnpm playwright test --debug cells.spec.ts
```

### 3. Running Test Notebooks

Create test notebooks to verify UI components:

```bash
# Run tutorial notebooks
marimo tutorial intro

# Run smoke tests (visual verification)
marimo edit marimo/_smoke_tests/inputs.py
marimo edit marimo/_smoke_tests/arrays_and_dicts.py
marimo edit marimo/_smoke_tests/dataframe.py
```

## Testing Different Features

### Data Tables & Visualizations
```bash
marimo edit marimo/_smoke_tests/dataframe.py
marimo edit marimo/_smoke_tests/data_explorer.py
```

### UI Components
```bash
marimo edit marimo/_smoke_tests/inputs.py
marimo edit marimo/_smoke_tests/forms.py
marimo edit marimo/_smoke_tests/buttons.py
```

### Layouts
```bash
marimo edit marimo/_smoke_tests/layout.py
marimo edit marimo/_smoke_tests/grid.py
marimo edit marimo/_smoke_tests/sidebar.py
```

### Charts & Plots
```bash
marimo edit examples/third_party/altair/altair_example.py
marimo edit examples/third_party/plotly/scatter_map.py
```

## Frontend Architecture

### Key Directories

```
frontend/
├── src/
│   ├── components/     # Reusable UI components
│   │   ├── ui/         # Base UI components (buttons, inputs, etc.)
│   │   ├── editor/     # Code editor components
│   │   └── data-table/ # Data visualization components
│   ├── core/           # Core application logic
│   │   ├── cells/      # Cell management
│   │   ├── kernel/     # Python kernel communication
│   │   └── websocket/  # WebSocket handling
│   ├── plugins/        # Plugin system for UI elements
│   └── pages/          # Application pages (edit, run, home)
├── e2e-tests/         # End-to-end test files
└── public/            # Static assets
```

### Key Files to Test Visually

1. **Cell Editor**: `src/components/editor/`
2. **Data Tables**: `src/components/data-table/`
3. **UI Plugins**: `src/plugins/impl/`
4. **Layout System**: `src/components/layout/`

## Common Development Tasks

### Adding a New UI Component

1. Create component in `frontend/src/components/ui/`
2. Add to Storybook: `frontend/src/stories/`
3. Test visually: `pnpm storybook`
4. Write e2e test: `frontend/e2e-tests/`

### Testing Reactive Updates

```bash
# Run a notebook with reactive cells
marimo edit examples/ui/batch_and_form.py

# Test UI element interactions
marimo edit examples/ui/slider.py
```

### Testing Mobile/Responsive Design

1. Open developer tools (F12)
2. Toggle device toolbar (Ctrl+Shift+M)
3. Test different screen sizes

## Debugging Tips

### Browser DevTools

- **React DevTools**: Install browser extension for component inspection
- **Network Tab**: Monitor WebSocket messages
- **Console**: Check for JavaScript errors
- **Elements**: Inspect CSS and DOM structure

### Frontend Logs

```bash
# Enable debug logs in browser console
localStorage.debug = 'marimo:*'

# Disable debug logs
delete localStorage.debug
```

### Visual Regression Testing

```bash
# Update visual snapshots
cd frontend
pnpm playwright test --update-snapshots

# Run with specific browser
pnpm playwright test --project=chromium
```

## Performance Testing

### Bundle Size Analysis

```bash
cd frontend
pnpm build
# Check dist/ folder for bundle sizes
```

### Runtime Performance

1. Open Chrome DevTools Performance tab
2. Start recording
3. Perform actions (run cells, scroll tables, etc.)
4. Stop recording and analyze

## Troubleshooting

### Hot Reload Not Working

```bash
# Clear cache and restart
rm -rf frontend/node_modules/.vite
pnpm dev
```

### WebSocket Connection Issues

```bash
# Check if backend is running
curl http://localhost:2718/health

# Run backend with debug logs
marimo -d edit --no-token
```

### Build Errors

```bash
# Clean and rebuild
rm -rf frontend/dist marimo/_static
make fe
```

## Useful Commands Summary

```bash
# Development
make dev                    # Start dev servers
make fe                     # Build frontend
make fe-check              # Lint & typecheck frontend
make fe-test               # Run frontend unit tests
make e2e                   # Run e2e tests

# Storybook
make storybook             # Launch component library

# Testing specific features
marimo edit --no-token     # Edit mode
marimo run notebook.py     # Run mode (read-only)
marimo tutorial intro      # Interactive tutorial
```

## Resources

- [marimo Documentation](https://docs.marimo.io)
- [React DevTools](https://react.dev/learn/react-developer-tools)
- [Playwright Documentation](https://playwright.dev)
- [Tailwind CSS](https://tailwindcss.com/docs)

## Theme Development & Customization

marimo supports extensive theming and visual customization:

### Built-in Themes
- **light**: Default light theme
- **dark**: Dark theme optimized for low-light environments  
- **system**: Automatically follows OS theme preference

### Testing Themes Visually

```bash
# Test theme switching in different notebooks
marimo edit examples/ui/slider.py

# Test with custom CSS
echo ':root { --marimo-primary: #ff6b6b; }' > custom.css
marimo edit --css custom.css examples/ui/forms.py

# Test theme-specific components
marimo edit marimo/_smoke_tests/theming/plotly_theme.py
```

### Custom CSS Development

1. **Create theme files**: Use CSS custom properties for consistent theming
2. **Test responsively**: Verify themes work on mobile and desktop
3. **Use light-dark()**: Support both light and dark modes automatically
4. **Target cells**: Use `data-cell-name` and `data-cell-role` attributes

Example custom theme:
```css
:root {
  --marimo-text-font: 'Inter', sans-serif;
  --marimo-primary: light-dark(#6366f1, #8b5cf6);
  --background: light-dark(#ffffff, #0f172a);
}

[data-cell-role="cell"] {
  border-radius: 12px;
  background: var(--background);
}
```

### Theme Configuration

Set theme in different ways:

```python
# Per-app configuration
app = marimo.App(css_file="my-theme.css")

# Script metadata (per-notebook)
# /// script
# [tool.marimo.display]
# theme = "dark"
# ///

# Global user config
marimo config set theme dark
```

For comprehensive theme development, see [THEME_GUIDE.md](THEME_GUIDE.md).

## Tips for Visual Development

1. **Use Storybook** for isolated component development
2. **Keep DevTools open** to monitor network and console
3. **Test in multiple browsers** (Chrome, Firefox, Safari)
4. **Use smoke tests** as visual verification checkpoints
5. **Enable source maps** for easier debugging
6. **Test both light and dark themes**
7. **Use CSS custom properties** for consistent theming
8. **Test responsive behavior** at different screen sizes

## Contributing

When making visual changes:

1. Test in Storybook first
2. Verify in the full application
3. Run relevant e2e tests
4. Update snapshots if needed
5. Test responsive behavior
6. Check accessibility (keyboard navigation, screen readers)