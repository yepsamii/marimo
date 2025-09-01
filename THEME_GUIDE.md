# marimo Theme Development Guide

This comprehensive guide covers how to add new themes and customize the appearance of marimo notebooks.

## Understanding marimo's Theme System

marimo uses a **CSS-based theming system** with built-in support for light/dark modes and custom CSS files. The theme system consists of:

1. **Built-in Themes**: `light`, `dark`, and `system` (follows OS preference)
2. **CSS Custom Properties**: Stable CSS variables for customization
3. **Custom CSS Files**: User-provided stylesheets for complete customization
4. **Dynamic Theme Switching**: Automatic light/dark mode detection

## Theme Architecture

### Backend Configuration

**Theme Types** (defined in `marimo/_config/config.py`):
```python
Theme = Literal["light", "dark", "system"]
```

**Theme Selection** (in `marimo/_utils/theme.py`):
```python
def get_current_theme() -> Theme:
    config_manager = get_default_config_manager(current_path=None)
    return config_manager.theme
```

### Frontend Theme System

**Theme Detection** (in `frontend/src/theme/useTheme.ts`):
- System theme detection via `prefers-color-scheme`
- VS Code integration for embedded mode
- Islands mode detection for embedded scenarios
- Configuration-based theme selection

**Theme Application** (in `frontend/src/theme/ThemeProvider.tsx`):
- Adds theme classes to `document.body`
- Manages CSS custom properties
- Handles theme transitions

**CSS Variables** (in `frontend/src/css/globals.css`):
```css
:root {
  /* Public API - stable across versions */
  --marimo-monospace-font: "Fira Mono", monospace;
  --marimo-text-font: "PT Sans", sans-serif;
  --marimo-heading-font: "Lora", serif;
  
  /* Color system using light-dark() function */
  --background: light-dark(hsl(0deg 0% 100%), hsl(150deg 7.7% 10.2%));
  --foreground: light-dark(hsl(222.2deg 47.4% 11.2%), hsl(155deg 7% 93%));
  --primary: light-dark(hsl(208deg 93.5% 47.4%), hsl(192deg 59.8% 39%));
  /* ... more color variables */
}

.dark {
  color-scheme: dark;
}
```

## Adding a New Built-in Theme

### Step 1: Update Backend Types

1. **Edit `marimo/_config/config.py`**:
```python
# Add your theme to the literal type
Theme = Literal["light", "dark", "system", "custom"]
```

### Step 2: Update Frontend Types

2. **Edit `frontend/src/theme/useTheme.ts`**:
```typescript
export type Theme = "light" | "dark" | "system" | "custom";
export const THEMES: Theme[] = ["light", "dark", "system", "custom"];
```

### Step 3: Add Theme Detection Logic

3. **Update theme resolution in `useTheme.ts`**:
```typescript
export const resolvedThemeAtom = atom((get) => {
  const theme = get(themeAtom);
  const codeTheme = get(codeThemeAtom);
  
  if (codeTheme !== undefined) {
    return codeTheme;
  }
  
  const prefersDarkMode = get(prefersDarkModeAtom);
  
  // Add your custom theme logic
  if (theme === "custom") {
    return "custom"; // or determine based on conditions
  }
  
  return theme === "system" ? (prefersDarkMode ? "dark" : "light") : theme;
});
```

### Step 4: Add CSS Styles

4. **Create theme styles in `frontend/src/css/globals.css`**:
```css
.custom,
.marimo:is(.custom *) {
  color-scheme: dark; /* or light */
  
  /* Override CSS custom properties for your theme */
  --background: hsl(240deg 10% 15%);
  --foreground: hsl(210deg 20% 90%);
  --primary: hsl(280deg 60% 60%);
  /* ... other color overrides */
}
```

### Step 5: Update Theme Provider

5. **Ensure `ThemeProvider.tsx` handles the new theme**:
```typescript
export const ThemeProvider: React.FC<PropsWithChildren> = memo(({ children }) => {
  const { theme } = useTheme();
  useLayoutEffect(() => {
    // This will automatically add 'custom' and 'custom-theme' classes
    document.body.classList.add(theme, `${theme}-theme`);
    return () => {
      document.body.classList.remove(theme, `${theme}-theme`);
    };
  }, [theme]);

  return children;
});
```

## Creating Custom CSS Themes

### Method 1: Custom CSS Files

Create a CSS file with your theme styles:

```css
/* custom-theme.css */
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600&display=swap');

:root {
  --marimo-monospace-font: 'JetBrains Mono', monospace;
  --marimo-text-font: 'Inter', sans-serif;
  --marimo-heading-font: 'Playfair Display', serif;
}

/* Custom color scheme */
:root {
  --background: light-dark(#fafafa, #1a1a1a);
  --foreground: light-dark(#333333, #e0e0e0);
  --primary: light-dark(#6366f1, #8b5cf6);
  --accent: light-dark(#f59e0b, #fbbf24);
}

/* Custom cell styling */
[data-cell-role="cell"] {
  border-radius: 12px;
  border: 1px solid light-dark(#e5e7eb, #374151);
  background: light-dark(#ffffff, #111827);
}

/* Custom output styling */
[data-cell-role="output"] {
  background: light-dark(#f9fafb, #0f172a);
  border-radius: 8px;
  border: 1px solid light-dark(#e5e7eb, #334155);
}
```

**Apply the theme**:

```python
import marimo as mo

# Method 1: App-level
app = mo.App(css_file="custom-theme.css")

# Method 2: Project-level (in pyproject.toml)
# [tool.marimo.display]
# custom_css = ["custom-theme.css"]
```

### Method 2: Inline Styles with CssVariables

```python
import marimo as mo

# Custom CSS variables for a specific layout
custom_vars = {
    "--marimo-text-font": "'Comic Sans MS', cursive",
    "--marimo-primary": "#ff6b6b",
    "--marimo-background": "#f8f9fa"
}

with mo.ui.CssVariables(custom_vars):
    mo.md("# This uses custom styling!")
```

## Advanced Theme Customization

### Targeting Specific Elements

```css
/* Target specific cell by name */
[data-cell-name='my_visualization'] {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  padding: 24px;
}

/* Style code editors */
.cm-editor {
  font-family: 'Fira Code', monospace;
  font-size: 14px;
  line-height: 1.6;
}

/* Custom scrollbars */
::-webkit-scrollbar {
  width: 8px;
}

::-webkit-scrollbar-track {
  background: var(--muted);
}

::-webkit-scrollbar-thumb {
  background: var(--primary);
  border-radius: 4px;
}
```

### Responsive Themes

```css
/* Mobile-first theming */
@media (max-width: 768px) {
  :root {
    --marimo-text-font: system-ui, sans-serif;
    --base-padding: 12px;
  }
  
  [data-cell-role="cell"] {
    margin: 8px 0;
    padding: var(--base-padding);
  }
}

/* Dark mode specific adjustments */
@media (prefers-color-scheme: dark) {
  :root {
    --shadow-intensity: 0.3;
    --border-opacity: 0.2;
  }
}
```

### Animation and Transitions

```css
/* Smooth theme transitions */
* {
  transition: 
    background-color 0.3s ease,
    border-color 0.3s ease,
    color 0.3s ease;
}

/* Cell hover effects */
[data-cell-role="cell"]:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

/* Fade-in animation for outputs */
[data-cell-role="output"] {
  animation: fadeIn 0.5s ease-in-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}
```

## Theme Configuration Options

### Global Configuration

**Via marimo config**:
```python
# Set theme in marimo settings
mo.config.theme = "dark"
```

**Via environment**:
```bash
# Force theme for all notebooks
export MARIMO_THEME=dark
```

### Per-Notebook Configuration

**Script metadata**:
```python
# /// script
# [tool.marimo.display]
# theme = "dark"
# custom_css = ["my-theme.css"]
# ///

import marimo as mo
```

### Project-Level Configuration

**In `pyproject.toml`**:
```toml
[tool.marimo.display]
theme = "dark"
custom_css = ["themes/main.css", "themes/components.css"]
```

## Testing Your Theme

### 1. Visual Testing

```python
# Create a test notebook with common elements
import marimo as mo
import pandas as pd
import matplotlib.pyplot as plt

# Test markdown
mo.md("""
# Heading 1
## Heading 2
Regular text with **bold** and *italic*.
- List item 1
- List item 2
""")

# Test code
def sample_function():
    return "Hello, World!"

# Test data display
df = pd.DataFrame({"A": [1, 2, 3], "B": [4, 5, 6]})
mo.as_html(df)

# Test plots
plt.figure(figsize=(8, 6))
plt.plot([1, 2, 3], [1, 4, 2])
plt.title("Sample Plot")
```

### 2. Cross-Browser Testing

Test your theme in:
- Chrome (Webkit)
- Firefox (Gecko)
- Safari (Webkit)
- Edge (Chromium)

### 3. Responsive Testing

```css
/* Add debug helpers */
.debug-breakpoints::before {
  content: "XS";
  position: fixed;
  top: 0;
  right: 0;
  background: red;
  color: white;
  padding: 4px;
}

@media (min-width: 640px) {
  .debug-breakpoints::before { content: "SM"; }
}

@media (min-width: 768px) {
  .debug-breakpoints::before { content: "MD"; }
}

@media (min-width: 1024px) {
  .debug-breakpoints::before { content: "LG"; }
}
```

## Sharing Your Theme

### Community Themes Repository

The marimo community maintains a [themes repository](https://github.com/Haleshot/marimo-themes) where you can:

1. **Browse existing themes**
2. **Download and use community themes**
3. **Contribute your own themes**

### Contributing a Theme

1. **Create your theme CSS file**
2. **Test thoroughly across different scenarios**
3. **Document your theme with screenshots**
4. **Submit a PR to the community repository**

Example theme structure:
```
my-theme/
├── theme.css          # Main theme file
├── README.md          # Documentation
├── preview-light.png  # Light mode preview
├── preview-dark.png   # Dark mode preview
└── demo.py           # Demo notebook
```

## Troubleshooting

### Common Issues

1. **CSS not loading**: Check file paths are relative to notebook location
2. **Theme not switching**: Clear browser cache, check CSS precedence
3. **Colors not working**: Ensure you're using supported CSS custom properties
4. **Mobile issues**: Test responsive breakpoints

### Debugging Tools

```javascript
// Check current theme in browser console
console.log(document.body.classList);

// Inspect CSS custom properties
getComputedStyle(document.documentElement)
  .getPropertyValue('--marimo-text-font');

// Debug theme detection
localStorage.debug = 'marimo:theme';
```

## Best Practices

1. **Use CSS Custom Properties**: Stick to the stable API variables
2. **Support Both Themes**: Use `light-dark()` function for color values
3. **Test Accessibility**: Ensure sufficient contrast ratios
4. **Mobile-First**: Design for mobile, enhance for desktop
5. **Performance**: Minimize CSS size and complexity
6. **Documentation**: Provide clear usage instructions

## Resources

- [marimo Theming Documentation](https://docs.marimo.io/guides/configuration/theming.html)
- [Community Themes Repository](https://github.com/Haleshot/marimo-themes)
- [CSS light-dark() Function](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value/light-dark)
- [CSS Custom Properties](https://developer.mozilla.org/en-US/docs/Web/CSS/--*)
- [Color Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)

---

## Quick Start Checklist

- [ ] Create a CSS file with your theme styles
- [ ] Test with sample content (markdown, code, data, plots)
- [ ] Verify light/dark mode compatibility
- [ ] Test on mobile devices
- [ ] Check accessibility (contrast, readability)
- [ ] Document your theme with examples
- [ ] Share with the community!