struct Resolved: Codable {
    let object: Pins
    let version: Int
}

struct Pins: Codable {
    let pins: [Pin]
}

struct Pin: Codable {
    let package: String
    let repositoryURL: String
    let state: PinState
}

struct PinState: Codable {
    let branch: String?
    let revision: String
    let version: String?
}
