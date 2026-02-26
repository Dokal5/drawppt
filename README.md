# DrawPPT — iPhone Wireframe to Editable PowerPoint

## Goal
Build an iPhone app where a user hand-draws rough wireframes, then AI converts them into clean UI frames and exports editable `.pptx` slides for refinement in Microsoft PowerPoint.

## MVP Scope

### 1) Input: Hand-Drawn Wireframe Capture
- iPhone canvas using Apple Pencil / finger input.
- Multi-page sketch support (one sketch = one future slide).
- Optional photo import of paper sketches.

### 2) AI Cleanup + Layout Understanding
- Detect common UI primitives from sketch:
  - buttons, text blocks, image placeholders, nav bars, tab bars, cards, lists, form fields.
- Normalize rough geometry into aligned, grid-based layout.
- Infer hierarchy and spacing from strokes.

### 3) Frame Generation
- Produce a polished wireframe frame per page:
  - consistent typography scale,
  - spacing system,
  - alignment,
  - optional style themes (low-fi, grayscale, minimal).

### 4) PPTX Export
- Map each frame to one slide.
- Preserve editability using native PowerPoint shapes/text boxes.
- Group related elements (e.g., card components) for easier editing.
- Keep a hidden metadata JSON blob in slide notes (optional) for re-import.

## Suggested Architecture

### iOS App (SwiftUI)
- `CanvasView` for freehand drawing.
- `DocumentStore` for multi-page sketches.
- `ExportManager` for calling backend and downloading `.pptx`.

### Backend Service
- **Vision model** for primitive detection + OCR (if handwritten labels).
- **Layout post-processor** for snapping, alignment, and component synthesis.
- **PPTX renderer**:
  - Option A: Python `python-pptx`
  - Option B: JS `pptxgenjs`

### Data Contract
- Sketch page -> normalized intermediate JSON:

```json
{
  "pageId": "p1",
  "canvas": {"width": 1170, "height": 2532},
  "elements": [
    {"type": "button", "x": 120, "y": 460, "w": 300, "h": 80, "text": "Continue"},
    {"type": "text", "x": 120, "y": 220, "w": 500, "h": 80, "text": "Welcome"}
  ],
  "style": {"mode": "lowfi", "theme": "gray"}
}
```

- JSON -> PPTX (one page per slide).

## AI Pipeline (Practical)
1. **Stroke preprocessing**: denoise, simplify paths.
2. **Shape proposal**: detect rectangles, lines, circles, icons.
3. **Semantic classification**: classify region into UI components.
4. **Constraint solving**: enforce spacing/grid/alignment.
5. **Text recovery**: OCR + language correction.
6. **Slide synthesis**: emit editable PPTX objects.

## Tech Choices (MVP)
- iOS: SwiftUI + PencilKit.
- API: FastAPI (Python).
- CV/AI: OpenCV + lightweight detector + optional multimodal LLM refinement.
- PPTX: `python-pptx` for deterministic editable output.
- Storage: S3-compatible object storage for sketch + export files.

## API Endpoints (Draft)
- `POST /v1/projects` → create project.
- `POST /v1/projects/{id}/pages` → upload sketch page image/strokes.
- `POST /v1/projects/{id}/generate` → run AI cleanup.
- `GET /v1/projects/{id}/preview` → return generated frame previews.
- `POST /v1/projects/{id}/export/pptx` → build pptx.
- `GET /v1/exports/{fileId}` → download pptx.

## Quality Bar
- Editable in PowerPoint without broken groups.
- Text remains text (not rasterized).
- 90%+ element placement consistency vs generated preview.
- Export under 10s for 10 slides (target).

## Risks & Mitigations
- **Messy sketches** → Add guided drawing templates and auto-snap hints.
- **Wrong component inference** → Tap-to-correct labels before export.
- **PPTX fidelity gaps** → Restrict to a supported shape subset for MVP.

## 6-Week MVP Plan
- **Week 1**: iOS drawing + project/page persistence.
- **Week 2**: Backend upload + preprocessing.
- **Week 3**: Component detection and normalization.
- **Week 4**: Style pass + preview rendering.
- **Week 5**: PPTX export with editable objects.
- **Week 6**: QA, performance tuning, TestFlight pilot.

## Next Steps
1. Confirm target users (PMs, founders, designers, students).
2. Pick backend language stack (Python recommended for AI + pptx speed).
3. Define supported UI component set v1.
4. Build a 3-screen happy-path prototype and validate export quality.

