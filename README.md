# DrawPPT

Turn hand-drawn mobile wireframes into clean, editable PowerPoint slides.

## What this repo now includes
- A runnable FastAPI backend starter.
- A normalized frame JSON schema (project/pages/elements/canvas/style).
- AI placeholder endpoint (`generate`) to validate request flow.
- Real PPTX export endpoint that converts frame JSON into editable slide shapes.
- Download endpoint for exported files.
- API tests for health, generate flow, and export/download.

## Quickstart

### 1) Install dependencies
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2) Run API
```bash
uvicorn app.main:app --reload --port 8000
```

### 3) Test API
```bash
pytest -q
```

## API

### `GET /health`
Returns service status.

### `POST /v1/projects/{project_id}/generate`
Validates and simulates AI generation.

### `POST /v1/projects/{project_id}/export/pptx`
Builds a PPTX from JSON input and returns export id + download URL.

### `GET /v1/exports/{export_id}`
Downloads generated `.pptx` file.

## Sample payload

```json
{
  "projectId": "demo",
  "pages": [
    {
      "pageId": "p1",
      "canvas": {"width": 1170, "height": 2532},
      "elements": [
        {"type": "text", "x": 100, "y": 120, "w": 500, "h": 80, "text": "Welcome"},
        {"type": "button", "x": 100, "y": 300, "w": 320, "h": 90, "text": "Continue"}
      ],
      "style": {"mode": "lowfi", "theme": "gray"}
    }
  ]
}
```

## What next (recommended)
1. Build iOS sketch capture app (SwiftUI + PencilKit).
2. Add upload endpoint for stroke/image pages.
3. Replace `generate` stub with real model inference and layout normalization.
4. Expand component mapping for richer editable PPTX output.
5. Add preview images and human-in-the-loop correction before export.

## iPhone Step 1 included
- Added `ios/` SwiftUI + PencilKit starter to capture hand-drawn wireframes, upload normalized payloads, export PPTX, and share the downloaded file.
- See `ios/README.md` for setup in Xcode and next steps.
