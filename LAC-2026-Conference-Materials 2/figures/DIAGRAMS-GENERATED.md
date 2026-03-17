# Generated Diagrams - LAC 2026

**Generated:** March 15, 2026  
**Status:** ✅ Ready for use in paper and presentation

---

## 📊 Available Diagrams

### 1. System Architecture Diagram

**Files:**

- `architecture-diagram.png` (128 KB, 1920×1080)
- `architecture-diagram.svg` (43 KB, vector)

**Content:**

- User interface layer (CLI/HTTP/ACP)
- Agent router with permission/session management
- Primary agents (csound, csound-sine, build)
- Specialized sub-agents (synthesis, effects, modulation)
- Csound-specific tools (compile, render, alternatives, patch, export, parallel)
- Support systems (4-tier RAG, validation, workspace, design tree)
- External dependencies (Csound binary, LLM providers)

**Use in paper:** Figure 1 or Figure 2 (system overview section)

---

### 2. Alternatives Workflow Comparison

**Files:**

- `alternatives-workflow.png` (97 KB, 1920×1080)
- `alternatives-workflow.svg` (34 KB, vector)

**Content:**

- Side-by-side comparison of traditional AI workflow vs DrC's alternatives-first approach
- Left side: Traditional "generate-and-refine" pattern (reactive)
- Right side: DrC "alternatives-first" pattern (proactive choice)
- Annotations showing user agency and learning opportunities

**Use in paper:** Figure 3 or Figure 4 (methodology section)

---

### 3. Design Tree Example

**Files:**

- `design-tree-example.png` (112 KB, 1920×1080)
- `design-tree-example.svg` (17 KB, vector)

**Content:**

- Non-linear exploration history
- Root: 3-operator FM synth
- Branch 1: Modulation index variations
- Branch 2: Reverb type alternatives (plate/Schroeder/spring)
- Current state highlighted
- Unexplored alternatives shown as potential paths

**Use in paper:** Figure 5 or Figure 6 (design tree/exploration section)

---

## 🎨 Color Palette Used

All diagrams use consistent colors:

- **Primary (Blue):** #2E86AB - Main agents, selected paths
- **Secondary (Purple):** #A23B72 - Sub-agents
- **Accent (Orange):** #F18F01 - Tools, current state
- **Success (Green):** #06A77D - Support systems, selected alternatives
- **Warning (Red):** #D84315 - Traditional workflow issues
- **Neutral (Gray):** #6C757D - Unexplored paths, external systems

---

## 📝 Usage Recommendations

### For Academic Paper:

- Use **SVG files** (vector format, scales perfectly)
- Convert to PDF if required by publisher: `inkscape <file>.svg --export-pdf=<file>.pdf --export-dpi=300`
- Minimum font size: 10pt in final render
- Ensure high contrast for grayscale printing

### For Presentation Slides:

- Use **PNG files** (1920×1080, optimized for screens)
- Transparent background allows flexible slide backgrounds
- High resolution ensures clarity on projectors

### For Web/HTML:

- Use **SVG files** (smaller file size, scalable)
- Browsers render SVG natively without loss of quality

---

## 🔧 Regeneration (if needed)

If you need to modify the diagrams:

1. Edit the `.mmd` source files
2. Regenerate with Mermaid CLI:

```bash
cd figures/

# PNG (for slides)
mmdc -i architecture-diagram.mmd -o architecture-diagram.png -w 1920 -H 1080 -b transparent

# SVG (for papers)
mmdc -i architecture-diagram.mmd -o architecture-diagram.svg -b transparent
```

Or use the online editor: https://mermaid.live/

---

## ✅ Checklist for Paper Submission

- [x] All diagrams generated in multiple formats
- [x] Consistent color palette applied
- [x] Transparent backgrounds for flexibility
- [x] High resolution for print quality
- [x] Vector formats available
- [ ] Diagrams referenced in paper text (Figure 1, Figure 2, etc.)
- [ ] Captions written for each diagram
- [ ] Diagrams embedded in final paper document

---

## 📂 File Summary

Total diagram files: **6 files**

- 3 PNG files (337 KB total)
- 3 SVG files (94 KB total)

All ready for immediate use in LAC 2026 paper and presentation.
