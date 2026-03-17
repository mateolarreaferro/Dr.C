# Figures for LAC 2026 Paper & Presentation

This directory contains figure source files in multiple formats for publication and presentation.

## ✅ Generated Diagrams (Ready to Use)

### PNG Files (for presentations, 1920×1080):

1. **architecture-diagram.png** (128 KB) - System architecture
2. **alternatives-workflow.png** (97 KB) - Alternatives-first workflow comparison
3. **design-tree-example.png** (112 KB) - Non-linear design exploration tree

### SVG Files (for papers, vector format):

1. **architecture-diagram.svg** (43 KB) - System architecture (scalable)
2. **alternatives-workflow.svg** (34 KB) - Workflow comparison (scalable)
3. **design-tree-example.svg** (17 KB) - Design tree (scalable)

## Source Files

1. **architecture-diagram.mmd** - System architecture (Mermaid source)
2. **alternatives-workflow.mmd** - Alternatives-first paradigm flowchart (Mermaid source)
3. **design-tree-example.mmd** - Design tree visualization (Mermaid source)
4. **educational-outcomes.csv** - Student learning data for charts
5. **block-diagram-reverb-filter.txt** - Signal flow example (ASCII art)
6. **block-diagram-fm-synth.txt** - FM synthesis routing (ASCII art)

## Generating Publication-Quality Images

### For Paper (High-Resolution)

```bash
# Convert Mermaid to PNG (300 DPI for print)
mmdc -i architecture-diagram.mmd -o architecture-diagram.png -w 3000 -H 2000

# Or use online tool: https://mermaid.live/
# Export as SVG, then convert with Inkscape:
inkscape architecture-diagram.svg --export-pdf=architecture-diagram.pdf --export-dpi=300
```

### For Presentation (Screen Resolution)

```bash
# Convert Mermaid to PNG (96 DPI for slides)
mmdc -i architecture-diagram.mmd -o architecture-diagram.png -w 1920 -H 1080

# Or export from Mermaid Live as PNG with "Fit to screen" option
```

## Tools

- **Mermaid CLI:** `npm install -g @mermaid-js/mermaid-cli`
- **Mermaid Live Editor:** https://mermaid.live/
- **Inkscape:** For SVG → PDF conversion (free, cross-platform)
- **R/Python:** For data visualization (educational-outcomes.csv)

## Color Palette (for consistency)

```
Primary:   #2E86AB (blue)
Secondary: #A23B72 (purple)
Accent:    #F18F01 (orange)
Success:   #06A77D (green)
Warning:   #D84315 (red-orange)
Neutral:   #6C757D (gray)

Background: #FFFFFF (white)
Text:       #212529 (dark gray)
```

## Recommendations for Publication

1. **Vector formats preferred:** SVG or PDF, not PNG/JPEG
2. **Font size:** Minimum 10pt in final rendered image
3. **Line width:** Minimum 1pt for visibility on projector
4. **High contrast:** Avoid light gray on white
5. **Color-blind safe:** Use patterns/textures in addition to color
6. **Consistency:** Use same color palette across all figures

## Alternative Tools

If Mermaid doesn't work for you:

- **draw.io (diagrams.net):** Free, browser-based, exports to many formats
- **Inkscape:** For manual SVG editing
- **TikZ (LaTeX):** For publication-quality diagrams (steep learning curve)
- **Python matplotlib:** For data charts
- **R ggplot2:** For statistical visualization
