import Foundation

struct Canvas: Codable {
    let width: Int
    let height: Int
}

struct Element: Codable, Identifiable {
    let id = UUID()
    let type: String
    let x: Double
    let y: Double
    let w: Double
    let h: Double
    let text: String?
}

struct Style: Codable {
    let mode: String
    let theme: String
}

struct FramePage: Codable {
    let pageId: String
    let canvas: Canvas
    let elements: [Element]
    let style: Style
}

struct FrameDocument: Codable {
    let projectId: String
    let pages: [FramePage]
}
