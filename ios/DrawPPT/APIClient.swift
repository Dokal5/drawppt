import Foundation

final class APIClient {
    private let baseURL: URL

    struct ExportResponse: Decodable {
        let exportId: String
        let download: String
    }

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func generate(projectId: String, document: FrameDocument) async throws {
        let endpoint = baseURL.appendingPathComponent("/v1/projects/\(projectId)/generate")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(document)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    func exportPPTX(projectId: String, document: FrameDocument) async throws -> ExportResponse {
        let endpoint = baseURL.appendingPathComponent("/v1/projects/\(projectId)/export/pptx")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(document)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(ExportResponse.self, from: data)
    }

    func downloadExport(exportId: String) async throws -> URL {
        let endpoint = baseURL.appendingPathComponent("/v1/exports/\(exportId)")
        let (tempURL, response) = try await URLSession.shared.download(from: endpoint)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(exportId).pptx")

        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.moveItem(at: tempURL, to: destination)
        return destination
    }
}
