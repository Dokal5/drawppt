# iPhone Step 1 (SwiftUI + PencilKit)

This folder contains the first iOS client slice for DrawPPT:

- Freehand wireframe sketching with PencilKit.
- Basic project id entry.
- "Upload Step 1" action that sends normalized JSON to backend `POST /v1/projects/{projectId}/generate`.

## Files
- `DrawPPTApp.swift` — app entry point.
- `ContentView.swift` — canvas + controls + upload action.
- `SketchCanvasView.swift` — `PKCanvasView` bridge for SwiftUI.
- `APIClient.swift` — backend HTTP call.
- `Models.swift` — payload models.

## How to run
1. Open Xcode and create an iOS App target named `DrawPPT`.
2. Replace generated Swift files with the files in this folder.
3. Run backend at `http://127.0.0.1:8000` (simulator), or update `APIClient` base URL for physical device.
4. Build and run on Simulator/iPhone.

## Current limitations
- Upload currently sends a placeholder element synthesized from drawing bounds.
- No stroke/image upload endpoint integration yet.
- No direct PPTX export call from iOS yet (backend supports it already).

## Next iOS step
- Add real stroke/image upload and integrate `/export/pptx`, then present download/share sheet.
