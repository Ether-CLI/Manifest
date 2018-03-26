import Foundation

public struct ManifestError: Error {
    public let identifier: String
    public let reason: String
}

extension ManifestError {
    static func noStringAtRange(_ range: NSRange) -> ManifestError {
        return ManifestError(identifier: "noStringAtRange", reason: "No substring exists in string at range '\(range)'")
    }
}
