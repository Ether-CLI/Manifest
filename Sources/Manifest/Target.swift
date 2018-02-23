import Foundation

struct Target: Codable {
    let name: String
    let path: String?
    let publicHeadersPath: String?
    let dependencies: [String]
    let exclude: [String]
    let source: [String]
}
