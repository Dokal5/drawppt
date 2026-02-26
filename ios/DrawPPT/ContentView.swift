import PencilKit
import SwiftUI

struct ContentView: View {
    @State private var drawing = PKDrawing()
    @State private var projectId = "demo"
    @State private var statusText = "Draw your wireframe, then upload as Step 1 JSON."
    @State private var isLoading = false
    @State private var exportedFileURL: URL?

    // Change to your backend host if testing on device:
    // - iOS simulator can usually reach localhost directly.
    // - physical device should use your machine LAN IP.
    private let apiClient = APIClient(baseURL: URL(string: "http://127.0.0.1:8000")!)

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                SketchCanvasView(drawing: $drawing)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))

                TextField("Project ID", text: $projectId)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Clear") {
                        drawing = PKDrawing()
                        statusText = "Canvas cleared."
                        exportedFileURL = nil
                    }

                    Spacer()

                    Button(isLoading ? "Uploading..." : "Upload Step 1") {
                        Task { await uploadStepOne() }
                    }
                    .disabled(isLoading || projectId.isEmpty)

                    Button(isLoading ? "Exporting..." : "Export PPTX") {
                        Task { await exportPPTX() }
                    }
                    .disabled(isLoading || projectId.isEmpty)
                }

                if let exportedFileURL {
                    ShareLink(item: exportedFileURL) {
                        Label("Share Last Export", systemImage: "square.and.arrow.up")
                            .font(.footnote)
                    }
                }

                Text(statusText)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .navigationTitle("DrawPPT")
        }
    }

    private func makeStepOneDocument() -> FrameDocument {
        // Step 1 placeholder mapping:
        // We currently transform the drawing bounds into a single "card" element.
        // Later steps should run model inference to detect structured UI components.
        let bounds = drawing.bounds
        let width = max(Int(bounds.width), 1170)
        let height = max(Int(bounds.height), 2532)

        let element = Element(
            type: "card",
            x: 80,
            y: 120,
            w: Double(max(width - 160, 320)),
            h: Double(max(height - 240, 400)),
            text: "Sketch Placeholder"
        )

        let page = FramePage(
            pageId: "p1",
            canvas: Canvas(width: width, height: height),
            elements: [element],
            style: Style(mode: "lowfi", theme: "gray")
        )

        return FrameDocument(projectId: projectId, pages: [page])
    }

    private func uploadStepOne() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let document = makeStepOneDocument()
            try await apiClient.generate(projectId: projectId, document: document)
            statusText = "Upload success. Next: export pptx and share with PowerPoint."
        } catch {
            statusText = "Upload failed: \(error.localizedDescription)"
        }
    }

    private func exportPPTX() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let document = makeStepOneDocument()
            let exportResponse = try await apiClient.exportPPTX(projectId: projectId, document: document)
            let fileURL = try await apiClient.downloadExport(exportId: exportResponse.exportId)
            exportedFileURL = fileURL
            statusText = "Export ready: \(fileURL.lastPathComponent). Use Share to open in PowerPoint."
        } catch {
            statusText = "Export failed: \(error.localizedDescription)"
        }
    }
}
