import PencilKit
import SwiftUI

struct ContentView: View {
    @State private var drawing = PKDrawing()
    @State private var projectId = "demo"
    @State private var statusText = "Draw your wireframe, then upload as Step 1 JSON."
    @State private var isLoading = false

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
                    }

                    Spacer()

                    Button(isLoading ? "Uploading..." : "Upload Step 1") {
                        Task { await uploadStepOne() }
                    }
                    .disabled(isLoading || projectId.isEmpty)
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

    private func uploadStepOne() async {
        isLoading = true
        defer { isLoading = false }

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

        let document = FrameDocument(projectId: projectId, pages: [page])

        do {
            try await apiClient.generate(projectId: projectId, document: document)
            statusText = "Upload success. Next: call export endpoint and preview slide output."
        } catch {
            statusText = "Upload failed: \(error.localizedDescription)"
        }
    }
}
